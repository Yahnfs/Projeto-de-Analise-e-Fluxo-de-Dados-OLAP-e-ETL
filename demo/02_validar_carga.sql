-- Demo SSIS: conferencia apos executar o pacote
USE LojaDW;
GO

-- Esperado: 17 linhas carregadas e 3 rejeitadas (ids 5, 10 e 15)
SELECT COUNT(*) AS linhas_carregadas FROM dbo.FatoVendas;
SELECT COUNT(*) AS linhas_rejeitadas FROM dbo.VendasRejeitadas;

SELECT * FROM dbo.FatoVendas ORDER BY id_venda;
SELECT * FROM dbo.VendasRejeitadas ORDER BY id_venda;

-- Exemplo de analise que o dado limpo ja permite
SELECT categoria,
       SUM(quantidade)  AS itens_vendidos,
       SUM(valor_total) AS faturamento
FROM dbo.FatoVendas
GROUP BY categoria
ORDER BY faturamento DESC;
