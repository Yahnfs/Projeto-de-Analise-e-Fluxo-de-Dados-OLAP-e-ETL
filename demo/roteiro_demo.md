# Roteiro da demonstração prática — SSIS

Cenário: carregar `vendas.csv` (20 linhas) no banco `LojaDW`, convertendo os tipos,
calculando `valor_total` e separando as linhas com quantidade inválida.

Resultado esperado: **17 linhas em `FatoVendas`** e **3 em `VendasRejeitadas`** (ids 5, 10 e 15).

Tempo previsto ao vivo: 5 a 6 minutos.

**Pacote pronto:** `CargaVendas.dtsx`, nesta pasta, já tem tudo montado (seções 2 a 4).
Para usar: criar o projeto (seção 1) e, no Gerenciador de Soluções, clicar com o botão
direito em **Pacotes SSIS > Adicionar Pacote Existente** e escolher o arquivo. As seções
abaixo servem para montar o mesmo pacote do zero ao vivo, ou para explicar cada peça
abrindo o pacote pronto.

## Antes da apresentação (preparo, não faz parte da demo)

1. Instalar o **Visual Studio Community** (2026 ou 2022) com a carga de trabalho
   "Armazenamento e processamento de dados".
2. No Visual Studio: Extensões > Gerenciar Extensões > instalar
   **SQL Server Integration Services Projects 2022+** e reiniciar.
3. No SSMS, conectar em `localhost\SQLEXPRESS` e executar `01_preparar_banco.sql`.
4. Fazer um ensaio completo e **gravar a tela** como reserva, caso algo falhe ao vivo.

Observação: o SQL Server Express não inclui o serviço do SSIS (catálogo SSISDB e
agendamento pelo Agent). Isso não impede a demo: o pacote é executado pelo próprio
Visual Studio e grava normalmente no Express.

## 1. Criar o projeto

- Arquivo > Novo > Projeto > **Integration Services Project** > nome `DemoVendas`.
- Mostrar à turma: aba **Fluxo de Controle** (Control Flow), aba **Fluxo de Dados**
  (Data Flow), a Caixa de Ferramentas do SSIS e a área **Gerenciadores de Conexões**.

## 2. Gerenciadores de conexão

- **Arquivo simples (Flat File)**: botão direito em Gerenciadores de Conexões >
  Nova Conexão de Arquivo Simples.
  - Arquivo: clicar em **Procurar** e escolher o `vendas.csv` desta pasta `demo`
    (o SSIS guarda o caminho completo do arquivo, não um caminho relativo)
  - Marcar "Nomes de colunas na primeira linha de dados"
  - Aba Colunas: delimitador de coluna **ponto e vírgula {;}**
  - Conferir a prévia com as 6 colunas.
- **OLE DB**: Nova Conexão OLE DB > Novo.
  - Provedor: Microsoft OLE DB Driver for SQL Server
  - Servidor: `localhost\SQLEXPRESS` · Autenticação do Windows · Banco: `LojaDW`
  - Se aparecer erro de certificado, marcar "Confiar no certificado do servidor".

## 3. Fluxo de Controle

1. Arrastar uma **Tarefa Executar SQL** (Execute SQL Task), nome `Limpar tabelas`.
   - Connection: a conexão OLE DB
   - SQLStatement:
     ```sql
     TRUNCATE TABLE dbo.FatoVendas; TRUNCATE TABLE dbo.VendasRejeitadas;
     ```
2. Arrastar uma **Tarefa Fluxo de Dados** (Data Flow Task), nome `Carregar vendas`.
3. Ligar a seta verde da primeira na segunda (restrição de precedência: só carrega
   se a limpeza der certo).

## 4. Fluxo de Dados (duplo clique em `Carregar vendas`)

1. **Origem de Arquivo Simples** (Flat File Source): escolher a conexão do CSV.
2. **Conversão de Dados** (Data Conversion): marcar as colunas e definir

   | Coluna de entrada | Alias de saída | Tipo de dados |
   |---|---|---|
   | id_venda | id_venda_int | inteiro com sinal de quatro bytes [DT_I4] |
   | data_venda | data_venda_dt | data do banco de dados [DT_DBDATE] |
   | quantidade | quantidade_int | inteiro com sinal de quatro bytes [DT_I4] |
   | preco_unitario | preco_num | numérico [DT_NUMERIC], precisão 10, escala 2 |

3. **Coluna Derivada** (Derived Column): adicionar como nova coluna
   - Nome: `valor_total`
   - Expressão: `(DT_NUMERIC,12,2)(quantidade_int * preco_num)`
4. **Divisão Condicional** (Conditional Split):
   - Saída `Validas`, condição: `quantidade_int > 0`
   - Nome da saída padrão: `Rejeitadas`
5. **Destino OLE DB** nº 1, ligado à saída `Validas`: tabela `dbo.FatoVendas`.
   Na aba Mapeamentos, ligar `id_venda_int`, `data_venda_dt`, `quantidade_int` e
   `preco_num` às colunas correspondentes; `produto`, `categoria` e `valor_total`
   são mapeadas pelo nome.
6. **Destino OLE DB** nº 2, ligado à saída `Rejeitadas`: tabela `dbo.VendasRejeitadas`,
   com o mesmo mapeamento (sem `valor_total`).

## 5. Executar

- Pressionar **F5** (ou Iniciar).
- Mostrar os marcadores verdes e a contagem de linhas nas setas:
  20 linhas na origem, 17 para `FatoVendas`, 3 para `VendasRejeitadas`.
- Parar a depuração (Shift+F5).

## 6. Validar no SSMS

- Executar `02_validar_carga.sql` e mostrar as contagens, as 3 linhas rejeitadas
  e o faturamento por categoria (o tipo de consulta que o dado limpo já permite).

## Se algo der errado

| Sintoma | Causa provável | Correção |
|---|---|---|
| Prévia do CSV com uma coluna só | Delimitador errado | Trocar para ponto e vírgula na aba Colunas |
| Erro de truncamento no destino | Coluna de texto maior que a da tabela | Conferir o tamanho da coluna (50) na aba Avançado da conexão do arquivo |
| Falha de login na conexão OLE DB | Instância ou certificado | Usar `localhost\SQLEXPRESS` e confiar no certificado do servidor |
| Violação de chave primária | Tabela já tinha dados | Garantir que a Tarefa Executar SQL roda antes do fluxo de dados |
