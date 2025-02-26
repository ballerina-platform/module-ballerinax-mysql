/*
 * Copyright (c) 2025, WSO2 LLC. (http://www.wso2.org)
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

package io.ballerina.stdlib.mysql.compiler.analyzer;

import io.ballerina.compiler.syntax.tree.BasicLiteralNode;
import io.ballerina.compiler.syntax.tree.ExpressionNode;
import io.ballerina.compiler.syntax.tree.FunctionArgumentNode;
import io.ballerina.compiler.syntax.tree.FunctionCallExpressionNode;
import io.ballerina.compiler.syntax.tree.NamedArgumentNode;
import io.ballerina.compiler.syntax.tree.SeparatedNodeList;
import io.ballerina.compiler.syntax.tree.SimpleNameReferenceNode;
import io.ballerina.projects.Document;
import io.ballerina.projects.plugins.AnalysisTask;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.scan.Reporter;
import io.ballerina.tools.diagnostics.Location;

public class SecurePasswordAnalyzer implements AnalysisTask<SyntaxNodeAnalysisContext> {
    private final Reporter reporter;

    public SecurePasswordAnalyzer(Reporter reporter) {
        this.reporter = reporter;
    }

    @Override
    public void perform(SyntaxNodeAnalysisContext context) {
        if (!(context.node() instanceof FunctionCallExpressionNode functionCall)) {
            return;
        }
        SeparatedNodeList<FunctionArgumentNode> arguments = functionCall.arguments();
        boolean hasSecurePassword = false;
        for (FunctionArgumentNode argument : arguments) {
            if (argument instanceof NamedArgumentNode namedArgument) {
                if ("password".equals(namedArgument.argumentName().toString())) {
                    ExpressionNode expression = namedArgument.expression();
                    if (expression instanceof BasicLiteralNode basicLiteralNode) {
                        String passwordValue = basicLiteralNode.literalToken().text();
                        passwordValue = passwordValue.substring(1, passwordValue.length() - 1);
                        // Check if password is empty or weak
                        if (passwordValue.isEmpty()) {
                            reportPasswordVulnerability(context, functionCall);
                        } else {
                            hasSecurePassword = true;
                        }
                    } else if (expression instanceof SimpleNameReferenceNode) {
                        String passwordValue = ((SimpleNameReferenceNode) expression).name().toString();
                        if (passwordValue.isEmpty()) {
                            reportPasswordVulnerability(context, functionCall);
                        } else {
                            hasSecurePassword = true;
                        }
                    } else {
                        reportPasswordVulnerability(context, functionCall);
                    }
                }
            }
        }
        if (!hasSecurePassword) {
            reportPasswordVulnerability(context, functionCall);
        }
    }

    private void reportPasswordVulnerability(SyntaxNodeAnalysisContext context,
                                             FunctionCallExpressionNode functionCall) {
        Document document = getDocument(context);
        Location location = functionCall.location();
        this.reporter.reportIssue(document, location, MySQLRule.USE_SECURE_PASSWORD.getId());
    }

    public static Document getDocument(SyntaxNodeAnalysisContext context) {
        return context.currentPackage().module(context.moduleId()).document(context.documentId());
    }
}
