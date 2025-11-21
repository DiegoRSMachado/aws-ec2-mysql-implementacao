-- Script de Inicializacao de Banco de Dados RH
-- Projeto: Implementacao de Banco de Dados na AWS EC2

CREATE DATABASE Trabalho;
USE Trabalho;

-- Criacao da Tabela de Funcionarios
CREATE TABLE Funcionarios (
    id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cargo VARCHAR(50),
    salario DECIMAL(10,2),
    data_admissao DATE,
    departamento_id INT
);

-- Populando dados para teste
INSERT INTO Funcionarios (nome, cargo, salario, data_admissao, departamento_id) 
VALUES 
('João Silva', 'Analista', 3500.00, '2023-03-15', 1),
('Maria Souza', 'Gerente', 5500.00, '2021-06-01', 2),
('Carlos Almeida', 'Desenvolvedor', 4000.00, '2022-10-10', 1);

-- Validacao
SELECT * FROM Funcionarios;
