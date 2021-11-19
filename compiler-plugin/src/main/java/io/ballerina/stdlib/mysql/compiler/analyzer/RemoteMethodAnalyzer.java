/*
 * Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
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

import io.ballerina.compiler.api.symbols.ModuleSymbol;
import io.ballerina.compiler.api.symbols.Symbol;
import io.ballerina.compiler.api.symbols.TypeReferenceTypeSymbol;
import io.ballerina.compiler.api.symbols.TypeSymbol;
import io.ballerina.compiler.syntax.tree.ExpressionNode;
import io.ballerina.compiler.syntax.tree.RemoteMethodCallActionNode;
import io.ballerina.projects.plugins.AnalysisTask;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.stdlib.mysql.compiler.Constants;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.diagnostics.DiagnosticFactory;
import io.ballerina.tools.diagnostics.DiagnosticInfo;
import io.ballerina.tools.diagnostics.DiagnosticSeverity;
import org.ballerinalang.util.diagnostic.DiagnosticErrorCode;

import java.util.List;
import java.util.Optional;

import static io.ballerina.stdlib.mysql.compiler.MySQLDiagnosticsCode.MYSQL_101;
import static io.ballerina.stdlib.mysql.compiler.MySQLDiagnosticsCode.MYSQL_102;
import static org.ballerinalang.util.diagnostic.DiagnosticErrorCode.CANNOT_INFER_TYPE_FOR_PARAM;

/**
 * MySQL Client remote call analyzer.
 */
public class RemoteMethodAnalyzer implements AnalysisTask<SyntaxNodeAnalysisContext> {

    @Override
    public void perform(SyntaxNodeAnalysisContext ctx) {
        RemoteMethodCallActionNode node = (RemoteMethodCallActionNode) ctx.node();
        List<Diagnostic> diagnostics = ctx.semanticModel().diagnostics();
        diagnostics.stream()
                .filter(diagnostic -> diagnostic.diagnosticInfo().severity() == DiagnosticSeverity.ERROR)
                .filter(diagnostic ->
                        diagnostic.diagnosticInfo().code().equals(CANNOT_INFER_TYPE_FOR_PARAM.diagnosticId()) ||
                                diagnostic.diagnosticInfo().code().equals(
                                      DiagnosticErrorCode.INCOMPATIBLE_TYPE_FOR_INFERRED_TYPEDESC_VALUE.diagnosticId()))
                .filter(diagnostic -> diagnostic.location().lineRange().equals(node.location().lineRange()))
                .forEach(diagnostic -> addHint(ctx, node));
    }

    private void addHint(SyntaxNodeAnalysisContext ctx, RemoteMethodCallActionNode node) {
        ExpressionNode methodExpression = node.expression();
        Optional<TypeSymbol> methodExpReferenceType = ctx.semanticModel().typeOf(methodExpression);
        if (methodExpReferenceType.isEmpty()) {
            return;
        }
        TypeReferenceTypeSymbol methodExpTypeSymbol = (TypeReferenceTypeSymbol) methodExpReferenceType.get();
        Optional<ModuleSymbol> optionalModuleSymbol = methodExpTypeSymbol.getModule();
        if (optionalModuleSymbol.isEmpty()) {
            return;
        }
        ModuleSymbol module = optionalModuleSymbol.get();
        if (!(module.id().orgName().equals(Constants.BALLERINAX) && module.id().moduleName().equals(Constants.MYSQL))) {
            return;
        }
        String objectName = ((TypeReferenceTypeSymbol) methodExpReferenceType.get()).definition().getName().get();
        if (!objectName.equals(Constants.Client.CLIENT)) {
            return;
        }

        Optional<Symbol> methodSymbol = ctx.semanticModel().symbol(node.methodName());
        if (methodSymbol.isEmpty()) {
            return;
        }
        Optional<String> methodName = methodSymbol.get().getName();
        if (methodName.isEmpty()) {
            return;
        }

        switch (methodName.get()) {
            case Constants.Client.QUERY:
                ctx.reportDiagnostic(DiagnosticFactory.createDiagnostic(
                        new DiagnosticInfo(MYSQL_101.getCode(), MYSQL_101.getMessage(), MYSQL_101.getSeverity()),
                        node.location()));
                break;
            case Constants.Client.QUERY_ROW:
                ctx.reportDiagnostic(DiagnosticFactory.createDiagnostic(
                        new DiagnosticInfo(MYSQL_102.getCode(), MYSQL_102.getMessage(), MYSQL_102.getSeverity()),
                        node.location()));
                break;
            default:
                return;
        }
    }
}
