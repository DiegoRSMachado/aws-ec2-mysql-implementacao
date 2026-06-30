# AWS EC2 + MySQL — Implementação com Acesso Seguro

Servidor de banco **MySQL 8** em instância **AWS EC2 (Ubuntu)** para um schema de RH,
com foco em **acesso remoto seguro** (sem expor o banco à internet), usuário de aplicação
com **privilégio mínimo** e schema íntegro (integridade referencial + utf8mb4).

Lab acadêmico/supervisionado (SENAC-DF).

## Decisão central de segurança: NÃO expor a porta 3306

O erro comum é abrir a porta 3306 no Security Group para acesso remoto. MySQL exposto à
internet é um dos alvos mais varridos por bots (T1190). A abordagem correta usa **túnel SSH**
pela porta 22 (já aberta para gestão): o MySQL escuta apenas em `127.0.0.1`, e o tráfego do
Workbench trafega **cifrado dentro do SSH**. A porta do banco nunca fica pública.

| Item | Errado (comum) | Golden Path (aqui) |
|---|---|---|
| Porta 3306 no Security Group | Aberta p/ `0.0.0.0/0` | **Não aberta** — acesso por túnel SSH |
| `bind-address` do MySQL | `0.0.0.0` | `127.0.0.1` (loopback) |
| Usuário de conexão | `root` | `app_rh` com privilégio mínimo |
| Acesso do Workbench | TCP direto na 3306 | **Standard TCP/IP over SSH** |

## Security Group (AWS) — regras de entrada

| Porta | Protocolo | Origem | Justificativa |
|---|---|---|---|
| 22 | TCP | **Seu IP** (`x.x.x.x/32`), não `0.0.0.0/0` | Gestão + túnel SSH |
| 80/443 | TCP | conforme necessidade | **Só se houver servidor web** — este lab é só banco; remova se não usar |

> A porta **3306 não entra na lista**. Esse é o ponto. Se precisar mesmo de TCP direto
> (não recomendado), restrinja a origem a um IP fixo de gerência — jamais `0.0.0.0/0`.

## Arquivos

| Arquivo | Função |
|---|---|
| `01_schema.sql` | Cria banco/tabelas (idempotente, utf8mb4, FK, índice) e popula dados |
| `02_security_least_privilege.sql` | Cria o usuário `app_rh` com privilégio mínimo |

## O que foi corrigido do schema original

- **`SET NAMES utf8mb4` + charset do banco/tabela**: sem isso, acento grava corrompido
  (`João` virava `JoÃ£o`) — bug confirmado em teste. Agora grava correto.
- **Integridade referencial**: criada a tabela `Departamentos` e uma `FOREIGN KEY` em
  `Funcionarios.departamento_id`. Antes a coluna apontava para o nada.
- **Idempotência**: `CREATE ... IF NOT EXISTS` — o script roda novamente sem quebrar.
- **`ENGINE=InnoDB` + índice** no campo de FK (essencial para joins e para a própria FK).

## Como usar

### 1. Aplicar o schema (no servidor, via SSH)
```bash
sudo mysql < 01_schema.sql
```

### 2. Criar o usuário de aplicação
```bash
# troque a senha placeholder antes de rodar
sudo mysql < 02_security_least_privilege.sql
```

### 3. Conectar o MySQL Workbench com segurança (túnel SSH)
No Workbench, nova conexão → **Connection Method: Standard TCP/IP over SSH**:
- **SSH Hostname:** `IP_PUBLICO_DA_EC2:22`
- **SSH Username:** `ubuntu` (+ sua chave `.pem`)
- **MySQL Hostname:** `127.0.0.1`  ·  **MySQL Port:** `3306`
- **Username:** `app_rh`

O Workbench abre o túnel SSH e fala com o MySQL local da EC2. Nada de 3306 exposto.

## Validação (testado em engine real)

```sql
-- Acentuação correta:
SELECT nome FROM Funcionarios;            -- João Silva, Maria Souza, Carlos Almeida

-- Integridade referencial (deve falhar com ERROR 1452):
INSERT INTO Funcionarios (nome, departamento_id) VALUES ('Teste', 999);

-- Privilégios mínimos do usuário:
SHOW GRANTS FOR 'app_rh'@'localhost';     -- só SELECT/INSERT/UPDATE/DELETE em Trabalho.*
```

## Mapa de controles

| Vetor | ATT&CK | Controle |
|---|---|---|
| Banco exposto na internet | T1190 | 3306 fechado; acesso por túnel SSH |
| Abuso de conta privilegiada | T1078 | usuário `app_rh` least-privilege |
| Sniffing do tráfego de banco | T1040 | tráfego cifrado dentro do SSH |

## Próximos passos

1. **TLS no MySQL** (`require_secure_transport=ON`) para defesa em profundidade além do túnel.
2. **Backup automatizado** (`mysqldump` + cron + cópia para S3 com versionamento).
3. **Auditoria** (MariaDB Audit Plugin / general_log) → enviar para Wazuh e detectar
   acessos anômalos ao banco de RH (dado sensível: salários).
4. **Rotação de credenciais** e uso do AWS Secrets Manager em vez de senha em arquivo.

---
**Autor:** Diego Machado · Lab SENAC-DF · Cloud / Database Security
