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

import io.ballerina.compiler.syntax.tree.ExplicitNewExpressionNode;
import io.ballerina.compiler.syntax.tree.ExpressionNode;
import io.ballerina.compiler.syntax.tree.FunctionArgumentNode;
import io.ballerina.compiler.syntax.tree.ImplicitNewExpressionNode;
import io.ballerina.compiler.syntax.tree.MappingConstructorExpressionNode;
import io.ballerina.compiler.syntax.tree.MappingFieldNode;
import io.ballerina.compiler.syntax.tree.NamedArgumentNode;
import io.ballerina.compiler.syntax.tree.PositionalArgumentNode;
import io.ballerina.compiler.syntax.tree.SeparatedNodeList;
import io.ballerina.compiler.syntax.tree.SpecificFieldNode;
import io.ballerina.projects.plugins.AnalysisTask;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.stdlib.mysql.compiler.Constants;
import io.ballerina.stdlib.mysql.compiler.Utils;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.diagnostics.DiagnosticFactory;
import io.ballerina.tools.diagnostics.DiagnosticInfo;
import io.ballerina.tools.diagnostics.DiagnosticSeverity;

import java.util.List;
import java.util.stream.Collectors;

import static io.ballerina.stdlib.mysql.compiler.Constants.CONNECTION_POOL_PARM_NAME;
import static io.ballerina.stdlib.mysql.compiler.Constants.OPTIONS_PARM_NAME;
import static io.ballerina.stdlib.mysql.compiler.Constants.UNNECESSARY_CHARS_REGEX;
import static io.ballerina.stdlib.mysql.compiler.MySQLDiagnosticsCode.SQL_101;
import static io.ballerina.stdlib.mysql.compiler.MySQLDiagnosticsCode.SQL_102;
import static io.ballerina.stdlib.mysql.compiler.MySQLDiagnosticsCode.SQL_103;
import static io.ballerina.stdlib.mysql.compiler.Utils.getTerminalNodeValue;
import static io.ballerina.stdlib.mysql.compiler.Utils.validateOptions;

/**
 * Validate fields of sql:Connection pool fields.
 */
public class InitializerParamAnalyzer implements AnalysisTask<SyntaxNodeAnalysisContext> {
    @Override
    public void perform(SyntaxNodeAnalysisContext ctx) {
        List<Diagnostic> diagnostics = ctx.semanticModel().diagnostics();
        for (Diagnostic diagnostic : diagnostics) {
            if (diagnostic.diagnosticInfo().severity() == DiagnosticSeverity.ERROR) {
                return;
            }
        }

        if (!(Utils.isMySQLClientObject(ctx, ((ExpressionNode) ctx.node())))) {
            return;
        }

        SeparatedNodeList<FunctionArgumentNode> arguments;
        if (ctx.node() instanceof ImplicitNewExpressionNode) {
            arguments = ((ImplicitNewExpressionNode) ctx.node()).parenthesizedArgList().get().arguments();
        } else {
            arguments = ((ExplicitNewExpressionNode) ctx.node()).parenthesizedArgList().arguments();
        }

        List<NamedArgumentNode> namedArgumentNodes = arguments.stream()
                .filter(argNode -> argNode instanceof NamedArgumentNode)
                .map(argNode -> (NamedArgumentNode) argNode)
                .collect(Collectors.toList());

        boolean namedNodeFound = namedArgumentNodes.size() > 0;

        ExpressionNode options = null;
        ExpressionNode connectionPool = null;
        if (namedNodeFound) {
            for (NamedArgumentNode node : namedArgumentNodes) {
                if (node.argumentName().name().text().equals(OPTIONS_PARM_NAME)) {
                    options = node.expression();
                }
                if (node.argumentName().name().text().equals(CONNECTION_POOL_PARM_NAME)) {
                    connectionPool = node.expression();
                }
            }
        } else if (arguments.size() == 7) {
            options = ((PositionalArgumentNode) arguments.get(5)).expression();
            connectionPool = ((PositionalArgumentNode) arguments.get(6)).expression();
        } else if (arguments.size() == 6) {
            options = ((PositionalArgumentNode) arguments.get(5)).expression();
        } else {
            return;
        }

        if (options instanceof MappingConstructorExpressionNode) {
            validateOptions(ctx, (MappingConstructorExpressionNode) options);
        }
        if (connectionPool instanceof MappingConstructorExpressionNode) {
            validateConnectionPool(ctx, (MappingConstructorExpressionNode) connectionPool);
        }
    }

    private void validateConnectionPool(SyntaxNodeAnalysisContext ctx, MappingConstructorExpressionNode pool) {
        SeparatedNodeList<MappingFieldNode> fields = pool.fields();
        for (MappingFieldNode field : fields) {
            String name = ((SpecificFieldNode) field).fieldName().toString()
                    .trim().replaceAll(UNNECESSARY_CHARS_REGEX, "");
            ExpressionNode valueNode = ((SpecificFieldNode) field).valueExpr().get();
            switch (name) {
                case Constants.ConnectionPool.MAX_OPEN_CONNECTIONS:
                    int maxOpenConnections = Integer.parseInt(getTerminalNodeValue(valueNode, "1"));
                    if (maxOpenConnections < 1) {
                        DiagnosticInfo diagnosticInfo = new DiagnosticInfo(SQL_101.getCode(), SQL_101.getMessage(),
                                SQL_101.getSeverity());

                        ctx.reportDiagnostic(
                                DiagnosticFactory.createDiagnostic(diagnosticInfo, valueNode.location()));

                    }
                    break;
                case Constants.ConnectionPool.MIN_IDLE_CONNECTIONS:
                    int minIdleConnection = Integer.parseInt(getTerminalNodeValue(valueNode, "0"));
                    if (minIdleConnection < 0) {
                        DiagnosticInfo diagnosticInfo = new DiagnosticInfo(SQL_102.getCode(), SQL_102.getMessage(),
                                SQL_102.getSeverity());
                        ctx.reportDiagnostic(
                                DiagnosticFactory.createDiagnostic(diagnosticInfo, valueNode.location()));

                    }
                    break;
                case Constants.ConnectionPool.MAX_CONNECTION_LIFE_TIME:
                    float maxConnectionTime = Float.parseFloat(getTerminalNodeValue(valueNode, "30"));
                    if (maxConnectionTime < 30) {
                        DiagnosticInfo diagnosticInfo = new DiagnosticInfo(SQL_103.getCode(), SQL_103.getMessage(),
                                SQL_103.getSeverity());
                        ctx.reportDiagnostic(
                                DiagnosticFactory.createDiagnostic(diagnosticInfo, valueNode.location()));

                    }
                    break;
                default:
                    // Can ignore all other fields
                    continue;
            }
        }
    }

}
