-- Criação do banco de dados
CREATE DATABASE metro_sp;
USE metro_sp;

-- Tabela de cargos
CREATE TABLE cargos (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL UNIQUE,
    PRIMARY KEY (id)
);

-- Tabela de tipos de extintores
CREATE TABLE tipos_extintores (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    tipo VARCHAR(50) NOT NULL UNIQUE,
    PRIMARY KEY (id)
);

-- Tabela de status de extintores
CREATE TABLE status_extintor (
    id INT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
);

-- Tabela de linhas do metrô
CREATE TABLE linhas (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL UNIQUE,
    codigo VARCHAR(10) UNIQUE,
    descricao TEXT,
    PRIMARY KEY (id)
);

select * from localizacoes;

CREATE TABLE localizacoes (
    ID_Localizacao INT NOT NULL AUTO_INCREMENT,
    Linha_ID INT UNSIGNED,
    Estacao VARCHAR(100) NOT NULL,  -- Nome da estação
    Descricao_Local VARCHAR(255),     -- Descrição detalhada do local onde o extintor está
    Observacoes TEXT,
    PRIMARY KEY (ID_Localizacao),
    FOREIGN KEY (Linha_ID) REFERENCES linhas(id)
);

CREATE TABLE capacidades (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    descricao VARCHAR(10) NOT NULL UNIQUE,
    PRIMARY KEY (id)
);

-- Inserindo os valores de capacidades
INSERT INTO capacidades (descricao)
VALUES 
    ('11/2'),
    ('21/2'),
    ('1Kg'),
    ('2Kg'),
    ('4Kg'),
    ('6Kg'),
    ('8Kg'),
    ('10Kg'),
    ('12Kg'),
    ('20Kg'),
    ('25Kg'),
    ('45Kg'),
    ('50Kg'),
    ('10L');

select * from extintores;

-- Tabela de extintores
CREATE TABLE extintores (
    Patrimonio INT NOT NULL,
    Tipo_ID INT UNSIGNED NOT NULL,
    Capacidade_ID INT UNSIGNED, -- Referência à tabela de capacidades
    Codigo_Fabricante VARCHAR(50),
    Data_Fabricacao DATE,
    Data_Validade DATE,
    Ultima_Recarga DATE,
    Proxima_Inspecao DATE,
    ID_Localizacao INT,
    QR_Code VARCHAR(100),
    Observacoes TEXT,
    Linha_ID INT UNSIGNED,
    status_id INT,
    PRIMARY KEY (Patrimonio),
    FOREIGN KEY (Tipo_ID) REFERENCES tipos_extintores(id),
    FOREIGN KEY (Capacidade_ID) REFERENCES capacidades(id),
    FOREIGN KEY (ID_Localizacao) REFERENCES localizacoes(ID_Localizacao),
    FOREIGN KEY (Linha_ID) REFERENCES linhas(id),
    FOREIGN KEY (status_id) REFERENCES status_extintor(id)
);

select * from historico_manutencao;

-- Tabela de histórico de manutenção
CREATE TABLE historico_manutencao (
    ID_Manutencao INT NOT NULL AUTO_INCREMENT,
    ID_Extintor INT,  -- Alterado para INT para coincidir com o tipo de Patrimonio
    Data_Manutencao DATE NOT NULL,
    Descricao TEXT,
    Responsavel_Manutencao VARCHAR(100),
    Observacoes TEXT,
    PRIMARY KEY (ID_Manutencao),
    FOREIGN KEY (ID_Extintor) REFERENCES extintores(Patrimonio)
);

-- Tabela de usuários
CREATE TABLE usuarios (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    matricula VARCHAR(20) NOT NULL UNIQUE,
    foto_perfil BLOB,
    cargo_id INT UNSIGNED,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    reset_password_expires DATETIME,
    PRIMARY KEY (id),
    FOREIGN KEY (cargo_id) REFERENCES cargos(id)
);
ALTER TABLE usuarios MODIFY COLUMN foto_perfil VARCHAR(255);
SET SQL_SAFE_UPDATES = 0;
DELETE FROM usuarios;
SELECT * FROM cargos;
ALTER TABLE usuarios
ADD COLUMN reset_password_token VARCHAR(255),
ADD COLUMN reset_password_expires DATETIME;
describe usuarios;
select * from usuarios;
SELECT id, nome, senha FROM usuarios WHERE email = 'lucasbarboza@gmail.com';
CREATE TABLE Problemas_Extintores (
    ID_Problema INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ID_Extintor INT NOT NULL,
    Problema VARCHAR(255) NOT NULL,
    Local VARCHAR(255) NOT NULL,
    Observacoes TEXT,
    Data_Registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ID_Extintor) REFERENCES extintores(Patrimonio)
);
-- Inserindo dados na tabela de cargos
INSERT INTO cargos (nome) VALUES 
('Gerente'),
('Técnico de Segurança'),
('Operador'),
('Manutenção'),
('Coordenador');

-- Inserindo dados na tabela de tipos de extintores
INSERT INTO tipos_extintores (tipo) VALUES 
('Pó Químico'),
('CO2'),
('Espuma'),
('Água'),
('Halon');

-- Inserindo dados na tabela de status de extintores
INSERT INTO status_extintor (nome) VALUES 
('Ativo'),
('Inativo'),
('Em Manutenção'),
('Aguardando Inspeção');

INSERT INTO status_extintor (nome) VALUES ('Vencido');

-- Inserindo dados na tabela de linhas do metrô
INSERT INTO linhas (nome, codigo, descricao) VALUES 
('Linha 1 - Azul', 'L1', 'Linha que liga a estação Jabaquara à estação Tucuruvi.'),
('Linha 2 - Verde', 'L2', 'Linha que liga a estação Vila Madalena à estação Vergueiro.'),
('Linha 3 - Vermelha', 'L3', 'Linha que liga a estação Palmeiras-Barra Funda à estação Corinthians-Itaquera.'),
('Linha 4 - Amarela', 'L4', 'Linha que liga a estação Luz à estação São Paulo-Morumbi.'),
('Linha 5 - Lilás', 'L5', 'Linha que liga a estação Capão Redondo à estação Chácara Klabin.');

-- Inserindo dados na tabela de localizacoes
INSERT INTO localizacoes (Linha_ID, Estacao, Descricao_Local, Observacoes) VALUES 
(1, 'Jabaquara', 'Perto da entrada principal, próximo à bilheteria.', 'Extintor de fácil acesso.'),
(1, 'Tucuruvi', 'Ao lado da escada rolante, próximo ao banheiro.', 'Verificar validade anualmente.'),
(2, 'Vila Madalena', 'Em frente à saída de emergência.', 'Extintor deve ser inspecionado mensalmente.'),
(3, 'Palmeiras-Barra Funda', 'Na plataforma, próximo ao acesso ao trem.', 'Extintor em local visível.'),
(4, 'Luz', 'Na área de espera, ao lado do caixa eletrônico.', 'Extintor precisa de manutenção.'),
(5, 'Capão Redondo', 'Próximo à entrada de serviços.', 'Extintor em local estratégico.');

-- Inserindo dados na tabela de extintores
INSERT INTO extintores (Patrimonio, Tipo_ID, Capacidade_ID, Codigo_Fabricante, Data_Fabricacao, Data_Validade, Ultima_Recarga, Proxima_Inspecao, ID_Localizacao, QR_Code, Observacoes, Linha_ID, status_id) VALUES 
(1001, 1, 3, 'ABC123', '2020-01-01', '2025-01-01', '2022-06-01', '2023-06-01', 1, 'http://example.com/qrcode1.png', 'Extintor em bom estado.', 1, 1),
(1002, 2, 4, 'DEF456', '2019-05-01', '2024-05-01', '2021-11-01', '2023-11-01', 2, 'http://example.com/qrcode2.png', 'Extintor precisa de manutenção.', 1, 2),
(1003, 3, 2, 'GHI789', '2021-03-01', '2026-03-01', '2022-09-01', '2023-09-01', 3, 'http://example.com/qrcode3.png', 'Extintor em local visível.', 2, 1),
(1004, 4, 1, 'JKL012', '2022-02-01', '2027-02-01', '2023-01-01', '2024-01-01', 4, 'http://example.com/qrcode4.png', 'Extintor em área de espera.', 3, 1),
(1005, 5, 5, 'MNO345', '2020-07-01', '2025-07-01', '2022-04-01', '2023-04-01', 5, 'http://example.com/qrcode5.png', 'Extintor próximo ao banheiro.', 4, 3);

-- Inserindo dados na tabela de histórico de manutencao
INSERT INTO historico_manutencao (ID_Extintor, Data_Manutencao, Descricao, Responsavel_Manutencao, Observacoes) VALUES 
(1001, '2022-06-01', 'Manutenção preventiva realizada.', 'João Silva', 'Tudo em ordem.'),
(1002, '2023-01-15', 'Troca de mangueira e verificação de pressão.', 'Maria Oliveira', 'Extintor em bom estado após manutenção.'),
(1003, '2022-09-01', 'Inspeção regular realizada.', 'Carlos Pereira', 'Sem anomalias encontradas.'),
(1004, '2023-02-10', 'Reabastecimento de espuma.', 'Ana Costa', 'Extintor pronto para uso.'),
(1005, '2023-04-05', 'Verificação de validade e pressão.', 'Lucas Santos', 'Extintor precisa de manutenção em breve.');

-- Inserindo dados na tabela de usuários
INSERT INTO usuarios (nome, email, senha, matricula, cargo_id) VALUES 

('Lucas Silva', 'mclucas2720@gmail.com', 'senha123', 'MATRICULA007', 1);