-- ============================================================================
-- 02_security_least_privilege.sql  ·  Usuário de aplicação com privilégio mínimo
-- Projeto: Implementação MySQL em AWS EC2 · Autor: Diego Machado
--
-- NUNCA conecte a aplicação/Workbench como root. Crie um usuário dedicado,
-- restrito ao banco Trabalho e ao host de acesso.
--
-- MITRE: mitiga T1078 (Valid Accounts / abuso de conta privilegiada)
--
-- IMPORTANTE: troque 'SENHA_FORTE_AQUI' por uma senha forte real antes de rodar.
-- O host 'localhost' assume acesso via TÚNEL SSH (recomendado). Se o acesso for
-- por IP de gerência fixo, troque por '%' e RESTRINJA no Security Group da AWS.
-- ============================================================================

CREATE USER IF NOT EXISTS 'app_rh'@'localhost'
    IDENTIFIED BY 'SENHA_FORTE_AQUI';

-- Apenas operações de dados no banco Trabalho. Sem DROP, sem GRANT, sem acesso
-- a outros bancos. Princípio do menor privilégio.
GRANT SELECT, INSERT, UPDATE, DELETE
    ON Trabalho.*
    TO 'app_rh'@'localhost';

FLUSH PRIVILEGES;

-- Conferir o que foi concedido:
SHOW GRANTS FOR 'app_rh'@'localhost';
