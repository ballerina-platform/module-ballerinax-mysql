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

package io.ballerina.stdlib.mysql.compiler.staticcodeanalyzer;

import io.ballerina.compiler.syntax.tree.ImplicitNewExpressionNode;
import io.ballerina.compiler.syntax.tree.ImportOrgNameNode;
import io.ballerina.compiler.syntax.tree.ImportPrefixNode;
import io.ballerina.compiler.syntax.tree.ModulePartNode;
import io.ballerina.compiler.syntax.tree.NamedArgumentNode;
import io.ballerina.compiler.syntax.tree.Node;
import io.ballerina.compiler.syntax.tree.ParenthesizedArgList;
import io.ballerina.compiler.syntax.tree.PositionalArgumentNode;
import io.ballerina.compiler.syntax.tree.QualifiedNameReferenceNode;
import io.ballerina.compiler.syntax.tree.UnionTypeDescriptorNode;
import io.ballerina.compiler.syntax.tree.VariableDeclarationNode;
import io.ballerina.projects.Document;
import io.ballerina.projects.DocumentId;
import io.ballerina.projects.Module;
import io.ballerina.projects.plugins.AnalysisTask;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.scan.Reporter;

import java.util.HashSet;
import java.util.Set;

import static io.ballerina.stdlib.mysql.compiler.staticcodeanalyzer.MySQLRule.USE_SECURE_PASSWORD;

/**
 * Analyzer to detect insecure password vulnerabilities.
 */
public class SecurePasswordAnalyzer implements AnalysisTask<SyntaxNodeAnalysisContext> {
    private final Reporter reporter;
    private static final String BALLERINAX = "ballerinax";
    private static final String MYSQL = "mysql";
    private static final String CLIENT = "Client";
    private static final String PASSWORD = "password";
    private final Set<String> mysqlPrefixes = new HashSet<>();

    public SecurePasswordAnalyzer(Reporter reporter) {
        this.reporter = reporter;
    }

    @Override
    public void perform(SyntaxNodeAnalysisContext context) {
        analyzeImports(context);
        ImplicitNewExpressionNode implicitNewExpression = (ImplicitNewExpressionNode) context.node();

        if (!isMySQLClient(implicitNewExpression)) {
            return;
        }

        if (implicitNewExpression.parenthesizedArgList().isEmpty()) {
            return;
        }

        ParenthesizedArgList parenthesizedArgList = implicitNewExpression.parenthesizedArgList().get();

        if (hasEmptyPasswordParameter(parenthesizedArgList)) {
            report(context, USE_SECURE_PASSWORD.getId());
        }
    }

    /**
     * Checks if the ImplicitNewExpressionNode is for the MySQL Client.
     *
     * @param implicitNewExpression the ImplicitNewExpressionNode to check
     * @return true if it is a MySQL Client, false otherwise
     */
    private boolean isMySQLClient(ImplicitNewExpressionNode implicitNewExpression) {
        return implicitNewExpression.parent() instanceof VariableDeclarationNode variableDeclaration
                && variableDeclaration.typedBindingPattern().typeDescriptor()
                instanceof UnionTypeDescriptorNode unionTypeDescriptor
                && unionTypeDescriptor.leftTypeDesc() instanceof QualifiedNameReferenceNode qualifiedNameReference
                && mysqlPrefixes.contains(qualifiedNameReference.modulePrefix().text().trim())
                && qualifiedNameReference.identifier().text().trim().equals(CLIENT);
    }

    /**
     * Checks if the ParenthesizedArgList contains an empty password parameter.
     *
     * @param parenthesizedArgList the ParenthesizedArgList to check
     * @return true if it contains an empty password parameter, false otherwise
     */
    private boolean hasEmptyPasswordParameter(ParenthesizedArgList parenthesizedArgList) {
        int index = 0;
        for (Node argument : parenthesizedArgList.arguments()) {
            if (argument instanceof NamedArgumentNode namedArgument) {
                if (isEmptyNamedPasswordArgument(namedArgument)) {
                    return true;
                }
            } else if (argument instanceof PositionalArgumentNode positionalArgument) {
                if (index == 2 && isEmptyPositionalPasswordArgument(positionalArgument)) {
                    return true;
                }
                index++;
            }
        }
        return false;
    }

    /**
     * Checks if the NamedArgumentNode is an empty password argument.
     *
     * @param namedArgument the NamedArgumentNode to check
     * @return true if it is an empty password argument, false otherwise
     */
    private boolean isEmptyNamedPasswordArgument(NamedArgumentNode namedArgument) {
        return namedArgument.argumentName().toString().trim().equals(PASSWORD)
                && namedArgument.expression().toString().trim().equals("\"\"");
    }

    /**
     * Checks if the PositionalArgumentNode is an empty password argument.
     *
     * @param positionalArgument the PositionalArgumentNode to check
     * @return true if it is an empty password argument, false otherwise
     */
    private boolean isEmptyPositionalPasswordArgument(PositionalArgumentNode positionalArgument) {
        return positionalArgument.expression().toString().trim().equals("\"\"");
    }

    /**
     * Reports an issue for the given context and rule ID.
     *
     * @param context the syntax node analysis context
     * @param ruleId  the ID of the rule to report
     */
    private void report(SyntaxNodeAnalysisContext context, int ruleId) {
        reporter.reportIssue(
                getDocument(context.currentPackage().module(context.moduleId()), context.documentId()),
                context.node().location(),
                ruleId
        );
    }

    /**
     * Retrieves the Document corresponding to the given module and document ID.
     *
     * @param module     the module
     * @param documentId the document ID
     * @return the Document for the given module and document ID
     */
    private static Document getDocument(Module module, DocumentId documentId) {
        return module.document(documentId);
    }

    /**
     * Analyzes imports to identify all prefixes used for the email module.
     *
     * @param context the syntax node analysis context
     */
    private void analyzeImports(SyntaxNodeAnalysisContext context) {
        Document document = getDocument(context.currentPackage().module(context.moduleId()), context.documentId());
        if (document.syntaxTree().rootNode() instanceof ModulePartNode modulePart) {
            modulePart.imports().forEach(importDeclaration -> {
                ImportOrgNameNode importOrgName = importDeclaration.orgName().orElse(null);
                if (importOrgName != null && BALLERINAX.equals(importOrgName.orgName().text())
                        && importDeclaration.moduleName().stream()
                        .anyMatch(moduleName -> MYSQL.equals(moduleName.text()))) {
                    ImportPrefixNode importPrefix = importDeclaration.prefix().orElse(null);
                    String prefix = importPrefix != null ? importPrefix.prefix().text() : MYSQL;
                    mysqlPrefixes.add(prefix);
                }
            });
        }
    }
}
