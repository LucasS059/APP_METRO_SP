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
SELECT * FROM Extintores WHERE Patrimonio = '1';
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
    foto_perfil VARCHAR(255),
    cargo_id INT UNSIGNED,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    reset_password_expires DATETIME,
    reset_password_token VARCHAR(255),
    PRIMARY KEY (id),
    FOREIGN KEY (cargo_id) REFERENCES cargos(id)
);

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
('Aguardando Inspeção'),
('Vencido');

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



