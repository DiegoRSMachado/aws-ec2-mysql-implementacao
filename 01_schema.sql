-- ============================================================================
-- 01_schema.sql  ·  Banco de RH (Trabalho)
-- Projeto: Implementação MySQL em AWS EC2 · Autor: Diego Machado
--
-- Idempotente (IF NOT EXISTS), utf8mb4 (acentuação PT-BR correta),
-- integridade referencial (Departamentos + FOREIGN KEY) e índice no FK.
-- ============================================================================

-- Garante que a CONEXÃO use utf8mb4 ao inserir (senão acento grava corrompido,
-- mesmo com a tabela em utf8mb4). Foi exatamente o bug pego em teste.
SET NAMES utf8mb4;

CREATE DATABASE IF NOT EXISTS Trabalho
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE Trabalho;

-- Tabela de departamentos (referenciada por Funcionarios)
CREATE TABLE IF NOT EXISTS Departamentos (
    id_departamento INT AUTO_INCREMENT PRIMARY KEY,
    nome            VARCHAR(80) NOT NULL,
    UNIQUE KEY uq_departamento_nome (nome)
) ENGINE=InnoDB;

-- Tabela de funcionários
CREATE TABLE IF NOT EXISTS Funcionarios (
    id_funcionario  INT AUTO_INCREMENT PRIMARY KEY,
    nome            VARCHAR(100) NOT NULL,
    cargo           VARCHAR(50),
    salario         DECIMAL(10,2),
    data_admissao   DATE,
    departamento_id INT,
    CONSTRAINT fk_funcionario_departamento
        FOREIGN KEY (departamento_id)
        REFERENCES Departamentos (id_departamento)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    KEY idx_departamento (departamento_id)
) ENGINE=InnoDB;

-- Seed de departamentos (idempotente)
INSERT INTO Departamentos (nome) VALUES
    ('Tecnologia'),
    ('Administrativo')
ON DUPLICATE KEY UPDATE nome = VALUES(nome);

-- Seed de funcionários
-- (re-execução duplica linhas; limpe a tabela antes se precisar repetir o seed)
INSERT INTO Funcionarios (nome, cargo, salario, data_admissao, departamento_id)
VALUES
    ('João Silva',     'Analista',      3500.00, '2023-03-15', 1),
    ('Maria Souza',    'Gerente',       5500.00, '2021-06-01', 2),
    ('Carlos Almeida', 'Desenvolvedor', 4000.00, '2022-10-10', 1);

-- Validação: join provando a integridade referencial
SELECT f.id_funcionario,
       f.nome,
       f.cargo,
       d.nome AS departamento
FROM Funcionarios f
LEFT JOIN Departamentos d ON f.departamento_id = d.id_departamento
ORDER BY f.id_funcionario;
