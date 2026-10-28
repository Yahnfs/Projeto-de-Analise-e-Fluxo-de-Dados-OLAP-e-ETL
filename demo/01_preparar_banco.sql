-- Demo SSIS: prepara o banco de destino (executar no SSMS antes da apresentacao)

IF DB_ID('LojaDW') IS NULL
    CREATE DATABASE LojaDW;
GO

USE LojaDW;
GO

IF OBJECT_ID('dbo.FatoVendas') IS NOT NULL DROP TABLE dbo.FatoVendas;
IF OBJECT_ID('dbo.VendasRejeitadas') IS NOT NULL DROP TABLE dbo.VendasRejeitadas;
GO

-- Destino das linhas validas
CREATE TABLE dbo.FatoVendas (
    id_venda       INT           NOT NULL PRIMARY KEY,
    data_venda     DATE          NOT NULL,
    produto        VARCHAR(50)   NOT NULL,
    categoria      VARCHAR(50)   NOT NULL,
    quantidade     INT           NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    valor_total    DECIMAL(12,2) NOT NULL
);

-- Destino das linhas barradas pela Divisao Condicional (quantidade <= 0)
CREATE TABLE dbo.VendasRejeitadas (
    id_venda       INT           NULL,
    data_venda     DATE          NULL,
    produto        VARCHAR(50)   NULL,
    categoria      VARCHAR(50)   NULL,
    quantidade     INT           NULL,
    preco_unitario DECIMAL(10,2) NULL
);
GO
