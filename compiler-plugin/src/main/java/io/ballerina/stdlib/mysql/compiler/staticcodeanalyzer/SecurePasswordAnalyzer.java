/*
 * Copyright (c) 2026, WSO2 LLC. (http://www.wso2.org)
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License");
 * You may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.stdlib.mysql.compiler.staticcodeanalyzer;

import io.ballerina.compiler.syntax.tree.BasicLiteralNode;
import io.ballerina.compiler.syntax.tree.ExplicitNewExpressionNode;
import io.ballerina.compiler.syntax.tree.ExpressionNode;
import io.ballerina.compiler.syntax.tree.FunctionArgumentNode;
import io.ballerina.compiler.syntax.tree.FunctionCallExpressionNode;
import io.ballerina.compiler.syntax.tree.ImplicitNewExpressionNode;
import io.ballerina.compiler.syntax.tree.NamedArgumentNode;
import io.ballerina.compiler.syntax.tree.Node;
import io.ballerina.compiler.syntax.tree.PositionalArgumentNode;
import io.ballerina.compiler.syntax.tree.SeparatedNodeList;
import io.ballerina.projects.Document;
import io.ballerina.projects.plugins.AnalysisTask;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.scan.Reporter;
import io.ballerina.stdlib.mysql.compiler.Utils;

public class SecurePasswordAnalyzer implements AnalysisTask<SyntaxNodeAnalysisContext> {
    private final Reporter reporter;

    public SecurePasswordAnalyzer(Reporter reporter) {
        this.reporter = reporter;
    }

    @Override
    public void perform(SyntaxNodeAnalysisContext context) {
        try {
            Node node = context.node();
            if (!Utils.isMySQLClientObject(context, (ExpressionNode) node)) {
                return;
            }

            SeparatedNodeList<FunctionArgumentNode> arguments = getArguments(node);

            if (arguments == null || arguments.isEmpty()) {
                return;
            }

            int argIndex = 0;
            for (FunctionArgumentNode argument : arguments) {
                ExpressionNode expression = null;

                if (argument instanceof NamedArgumentNode namedArgument) {
                    // Check Named Argument
                    String argName = namedArgument.argumentName().name().text();
                    if ("password".equals(argName)) {
                        expression = namedArgument.expression();
                    }
                } else if (argument instanceof PositionalArgumentNode positionalArgument) {
                    // Check Positional Argument: 3rd argument
                    if (argIndex == 2) {
                        expression = positionalArgument.expression();
                    }
                }

                if (expression != null) {
                    if (isWeakPassword(expression)) {
                        reportPasswordVulnerability(context, node);
                    }
                    // Stop scanning other arguments
                    return;
                }
                argIndex++;
            }
        } catch (RuntimeException e) {
            // Prevent crashing the Scanner
        }
    }

    private SeparatedNodeList<FunctionArgumentNode> getArguments(Node node) {
        if (node instanceof ImplicitNewExpressionNode implicitNew) {
            if (implicitNew.parenthesizedArgList().isPresent()) {
                return implicitNew.parenthesizedArgList().get().arguments();
            }
        } else if (node instanceof ExplicitNewExpressionNode explicitNew) {
            return explicitNew.parenthesizedArgList().arguments();
        } else if (node instanceof FunctionCallExpressionNode functionCall) {
            return functionCall.arguments();
        }
        return null;
    }

    /**
     * Checks if the password is weak.
     * Rules: Not Empty, Length >= 8, Contains Uppercase, Lowercase, Digit, Special Char
     */
    private boolean isWeakPassword(ExpressionNode expression) {
        if (expression instanceof BasicLiteralNode basicLiteralNode) {
            String text = basicLiteralNode.literalToken().text();

            if (text.length() >= 2 && text.startsWith("\"") && text.endsWith("\"")) {
                text = text.substring(1, text.length() - 1);
            }

            if (text.isEmpty()) {
                return true;
            }
            if (text.length() < 8) {
                return true;
            }

            boolean hasUpper = false;
            boolean hasLower = false;
            boolean hasDigit = false;
            boolean hasSpecial = false;

            for (char c : text.toCharArray()) {
                if (Character.isUpperCase(c)) {
                    hasUpper = true;
                } else if (Character.isLowerCase(c)) {
                    hasLower = true;
                } else if (Character.isDigit(c)) {
                    hasDigit = true;
                } else {
                    hasSpecial = true;
                }
            }
            return !(hasUpper && hasLower && hasDigit && hasSpecial);
        }
        return false;
    }

    private void reportPasswordVulnerability(SyntaxNodeAnalysisContext context, Node node) {
        Document document = context.currentPackage().module(context.moduleId()).document(context.documentId());
        this.reporter.reportIssue(document, node.location(), MySQLRule.USE_SECURE_PASSWORD.getId());
    }
}
