import pandas as pd
from io import StringIO
from typing import List

def ler_dados_csv(csv_string: str) -> pd.DataFrame:
    """Lê os dados em formato string/CSV e padroniza as colunas de data."""
    df = pd.read_csv(StringIO(csv_string))
    df['dt_ref'] = pd.to_datetime(df['dt_ref'])
    df['mes_ano'] = df['dt_ref'].dt.to_period('M').astype(str)
    return df

def calcular_pipeline_metricas(df: pd.DataFrame) -> pd.DataFrame:
    """5. Agrega faturamento, comissão e calcula a margem percentual por filial e mês."""
    df_agg = df.groupby(['filial', 'mes_ano']).agg(
        faturamento=('valor', 'sum'),
        comissao=('comissao_bruta', 'sum')
    ).reset_index()
    
    df_agg['margem_pct'] = (df_agg['comissao'] / df_agg['faturamento']) * 100
    return df_agg

def classificar_performance(df_agg: pd.DataFrame) -> pd.DataFrame:
    """6. Classifica cada filial por mês baseado em thresholds de faturamento."""
    
    def classificar(faturamento: float) -> str:
        # Mantém exatamente os critérios definidos no seu projeto
        if faturamento >= 100000:
            return 'Alta Performance'
        elif faturamento >= 75000:
            return 'Média'
        else:
            return 'Baixa'
            
    df_agg['performance'] = df_agg['faturamento'].apply(classificar)
    return df_agg

def gerar_insight_queda(df_raw: pd.DataFrame) -> List[str]:
    """7. Analisa o crescimento MoM e retorna um insight detalhado caso haja queda."""
    df_temp = df_raw.copy()
    
    # Prepara as bases agregadas por produto e por filial
    df_prod = df_temp.groupby(['filial', 'mes_ano', 'produto'])['valor'].sum().reset_index()
    df_filial = df_temp.groupby(['filial', 'mes_ano'])['valor'].sum().reset_index()
    
    insights = []
    
    for filial in df_filial['filial'].unique():
        # Isola os dados da filial e ordena cronologicamente
        sub_f = df_filial[df_filial['filial'] == filial].sort_values('mes_ano').copy()
        sub_f['faturamento_ant'] = sub_f['valor'].shift(1)
        sub_f['queda_pct'] = ((sub_f['valor'] - sub_f['faturamento_ant']) / sub_f['faturamento_ant']) * 100
        
        # Filtra apenas os meses em que ocorreu retração
        meses_queda = sub_f[sub_f['queda_pct'] < 0]
        
        for _, row in meses_queda.iterrows():
            mes_atual = row['mes_ano']
            meses_unicos = sorted(sub_f['mes_ano'].unique())
            mes_ant = meses_unicos[meses_unicos.index(mes_atual) - 1]
            
            # Isola a performance dos produtos para comparar os dois meses
            prod_ant = df_prod[(df_prod['filial'] == filial) & (df_prod['mes_ano'] == mes_ant)].set_index('produto')['valor']
            prod_atual = df_prod[(df_prod['filial'] == filial) & (df_prod['mes_ano'] == mes_atual)].set_index('produto')['valor']
            
            # Calcula a variação nominal para encontrar o ofensor (maior queda)
            delta_produtos = (prod_atual - prod_ant).fillna(-prod_ant)
            produto_maior_queda = delta_produtos.idxmin()
            
            # Formata a string de saída conforme o requisito
            insight = (f"A filial {filial} teve queda de {abs(row['queda_pct']):.1f}% em {mes_atual} "
                       f"puxada principalmente pelo produto {produto_maior_queda}.")
            insights.append(insight)
            
    return insights


if __name__ == "__main__":
    # Base de dados fornecida no teste
    csv_data = """dt_ref,id_cliente,filial,assessor,parceiro,produto,valor,comissao_bruta,custo
2026-01-05,1,RJ01,Joao,XP,Consorcio,50000,2500,500
2026-01-10,2,RJ01,Maria,CNP,Seguro,30000,1800,400
2026-01-15,3,SP01,Carlos,XP,Credito,70000,3500,1200
2026-01-20,4,SP01,Ana,BTG,Consorcio,40000,2000,600
2026-02-05,1,RJ01,Joao,XP,Consorcio,60000,3000,600
2026-02-12,5,RJ01,Marcos,CNP,Seguro,20000,1200,300
2026-02-18,6,SP01,Carlos,XP,Credito,80000,4000,1500
2026-02-25,7,SP01,Ana,BTG,Consorcio,30000,1500,500
2026-03-03,8,RJ01,Maria,CNP,Seguro,25000,1500,350
2026-03-10,9,RJ01,Joao,XP,Credito,90000,4500,2000
2026-03-15,10,SP01,Carlos,XP,Consorcio,50000,2500,700
2026-03-20,11,SP01,Ana,BTG,Seguro,35000,2100,800"""

    # Execução do fluxo principal
    df_bruto = ler_dados_csv(csv_data)
    
    df_pipeline = calcular_pipeline_metricas(df_bruto)
    print("--- 5. PIPELINE DE DADOS ---")
    print(df_pipeline)
    print("\n" + "="*50 + "\n")
    
    df_classificado = classificar_performance(df_pipeline)
    print("--- 6. CLASSIFICAÇÃO DE PERFORMANCE ---")
    print(df_classificado[['filial', 'mes_ano', 'faturamento', 'performance']])
    print("\n" + "="*50 + "\n")
    
    alertas = gerar_insight_queda(df_bruto)
    print("--- 7. INSIGHTS AUTOMÁTICOS ---")
    for alerta in alertas:
        print(f"- {alerta}")