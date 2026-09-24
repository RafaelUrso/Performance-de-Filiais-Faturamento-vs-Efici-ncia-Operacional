# Performance-de-Filiais-Faturamento-vs-Eficiencia-Operacional

Este repositório contém a resolução do teste técnico para a posição de Planejamento Estratégico e Performance. O escopo abrange a extração e tratamento de dados, bem como a análise de negócio focada em eficiência operacional e mitigação de riscos comerciais.

Estrutura de Arquivos
SQL.sql: Consultas SQL desenvolvidas para banco de dados relacional. Contém as lógicas de agregação para faturamento, comissões, margem de lucro, crescimento MoM (Month-over-Month) e cálculo de concentração de faturamento. O código emprega Common Table Expressions (CTEs) e Window Functions para garantir a precisão e a eficiência das sumarizações.

pipeline_performance.py: Script desenvolvido em Python responsável por executar o pipeline de processamento de dados. Realiza a leitura do arquivo CSV, a consolidação das métricas financeiras por filial e mês, a classificação de performance e a geração de insights automatizados sobre variações negativas, utilizando a biblioteca pandas.

Performance de Filiais: Faturamento vs Eficiência Operacional.pdf: Documento consolidado com as respostas analíticas e o dashboard executivo estruturado no Power BI. O relatório apresenta o diagnóstico detalhado sobre a relação inversa entre faturamento bruto e margem líquida, acompanhado das propostas de ação para mitigação de risco.

Instruções de Execução Local
Para a execução isolada do pipeline de processamento em Python, recomenda-se a configuração de um ambiente virtual. O script é compatível com Python 3.14.

Realize o clone do repositório:

git clone https://github.com/RafaelUrso/Performance-de-Filiais-Faturamento-vs-Efici-ncia-Operacional.git
cd nome-do-repositorio
Crie e ative o ambiente virtual:

python -m venv venv
source venv/bin/activate
Instale a dependência de manipulação de dados:

pip install pandas
Execute o script principal:

python pipeline_performance.py
Resumo Executivo e Conclusões
Análise de Eficiência: O diagnóstico aponta que o volume de faturamento bruto isolado não reflete a saúde financeira da operação. A filial RJ01 entregou maior lucro bruto e margem líquida que a filial SP01, operando com menor custo e sustentada por um mix de produtos de maior margem de contribuição (Seguros e Consórcios).

Mapeamento de Riscos: Foi identificado um elevado risco operacional e comercial (Key Person Risk) na filial de melhor performance, com 70% do faturamento atrelado a um único assessor. O documento executivo propõe ações práticas para mitigação de dependência, envolvendo reestruturação da esteira de prospecção e blindagem do profissional.
