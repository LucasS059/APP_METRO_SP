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

-- Tabela de localizações
CREATE TABLE localizacoes (
    ID_Localizacao INT NOT NULL AUTO_INCREMENT,
    Linha_ID INT UNSIGNED,
    Area VARCHAR(50) NOT NULL,
    Subarea VARCHAR(50),
    Local_Detalhado VARCHAR(100),
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
    foto_perfil BLOB,
    cargo_id INT UNSIGNED,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (cargo_id) REFERENCES cargos(id)
);

-- Inserção de tipos de extintores
INSERT INTO tipos_extintores (tipo) VALUES
('Pó Químico'),
('Água'),
('CO2'),
('Espuma'),
('Pó ABC');

-- Inserção de linhas
INSERT INTO linhas (nome, codigo, descricao) VALUES
('Linha 1 - Azul', 'L1', 'Linha que conecta o Norte ao Sul, passando pelo centro da cidade.'),
('Linha 2 - Verde', 'L2', 'Linha leste-oeste, atravessa a cidade de São Paulo de leste a oeste.'),
('Linha 3 - Vermelha', 'L3', 'Linha que conecta a Zona Leste à Zona Oeste da cidade, com grande movimentação no centro.'),
('Linha 4 - Amarela', 'L4', 'Linha que liga a Zona Oeste ao Centro, passa por grandes centros comerciais.'),
('Linha 5 - Lilás', 'L5', 'Linha que conecta a Zona Sul à Zona Oeste.'),
('Linha 6 - Laranja', 'L6', 'Linha que liga a Zona Norte à Zona Sul (ainda em construção).');

-- Inserção de status de extintores
INSERT INTO status_extintor (nome) VALUES
('Em uso'),
('Aprovado'),
('Vencido'),
('Em manutenção'),
('Fora de serviço');

-- Inserção de cargos
INSERT INTO cargos (nome) VALUES
('Operador de Estação'),
('Supervisor de Linha'),
('Técnico de Manutenção');

-- Inserção de localizações (Linha 1 - Azul)
INSERT INTO localizacoes (Linha_ID, Area, Subarea, Local_Detalhado, Observacoes) VALUES
(1, 'Zona Sul', 'Jabaquara', 'Estação Jabaquara', 'Observação da estação Jabaquara'),
(1, 'Zona Sul', 'Conceição', 'Estação Conceição', 'Observação da estação Conceição'),
(1, 'Zona Sul', 'São Judas', 'Estação São Judas', 'Observação da estação São Judas'),
(1, 'Centro', 'Vila Mariana', 'Estação Vila Mariana', 'Observação da estação Vila Mariana'),
(1, 'Centro', 'Liberdade', 'Estação Liberdade', 'Observação da estação Liberdade'),
(1, 'Centro', 'Sé', 'Estação Sé', 'Observação da estação Sé');

INSERT INTO localizacoes (Linha_ID, Area, Subarea, Local_Detalhado, Observacoes) VALUES
(2, 'Zona Leste', 'Vila Prudente', 'Estação Vila Prudente', 'Observação da estação Vila Prudente'),
(2, 'Zona Sul', 'Santos-Imigrantes', 'Estação Santos-Imigrantes', 'Observação da estação Santos-Imigrantes'),
(2, 'Zona Sul', 'Alto do Ipiranga', 'Estação Alto do Ipiranga', 'Observação da estação Alto do Ipiranga');

INSERT INTO localizacoes (Linha_ID, Area, Subarea, Local_Detalhado, Observacoes) VALUES
(3, 'Zona Leste', 'Tatuapé', 'Estação Tatuapé', 'Observação da estação Tatuapé'),
(3, 'Zona Leste', 'Brás', 'Estação Brás', 'Observação da estação Brás'),
(3, 'Centro', 'República', 'Estação República', 'Observação da estação República'),
(3, 'Centro', 'Anhangabaú', 'Estação Anhangabaú', 'Observação da estação Anhangabaú'),
(3, 'Centro', 'Sé', 'Estação Sé', 'Observação da estação Sé'),
(3, 'Zona Oeste', 'Pinheiros', 'Estação Pinheiros', 'Observação da estação Pinheiros');

INSERT INTO localizacoes (Linha_ID, Area, Subarea, Local_Detalhado, Observacoes) VALUES
(4, 'Zona Oeste', 'Butantã', 'Estação Butantã', 'Observação da estação Butantã'),
(4, 'Zona Oeste', 'Faria Lima', 'Estação Faria Lima', 'Observação da estação Faria Lima'),
(4, 'Zona Oeste', 'Santo Amaro', 'Estação Santo Amaro', 'Observação da estação Santo Amaro'),
(4, 'Centro', 'Paulista', 'Estação Paulista', 'Observação da estação Paulista'),
(4, 'Centro', 'Liberdade', 'Estação Liberdade', 'Observação da estação Liberdade'),
(4, 'Zona Sul', 'Vila Progredior', 'Estação Vila Progredior', 'Observação da estação Vila Progredior');

INSERT INTO localizacoes (Linha_ID, Area, Subarea, Local_Detalhado, Observacoes) VALUES
(5, 'Zona Sul', 'Itaim Bibi', 'Estação Itaim Bibi', 'Observação da estação Itaim Bibi'),
(5, 'Zona Sul', 'Vila Olímpia', 'Estação Vila Olímpia', 'Observação da estação Vila Olímpia'),
(5, 'Zona Sul', 'Chácara Santo Antônio', 'Estação Chácara Santo Antônio', 'Observação da estação Chácara Santo Antônio'),
(5, 'Centro', 'Centro', 'Estação Centro', 'Observação da estação Centro'),
(5, 'Centro', 'Vila Madalena', 'Estação Vila Madalena', 'Observação da estação Vila Madalena'),
(5, 'Zona Norte', 'Tucuruvi', 'Estação Tucuruvi', 'Observação da estação Tucuruvi');

INSERT INTO localizacoes (Linha_ID, Area, Subarea, Local_Detalhado, Observacoes) VALUES
(6, 'Zona Norte', 'Vila Guilherme', 'Estação Vila Guilherme', 'Observação da estação Vila Guilherme'),
(6, 'Zona Norte', 'Lapa', 'Estação Lapa', 'Observação da estação Lapa'),
(6, 'Zona Sul', 'Campo Limpo', 'Estação Campo Limpo', 'Observação da estação Campo Limpo'),
(6, 'Zona Sul', 'Santo Amaro', 'Estação Santo Amaro', 'Observação da estação Santo Amaro'),
(6, 'Zona Leste', 'São Miguel Paulista', 'Estação São Miguel Paulista', 'Observação da estação São Miguel Paulista'),
(6, 'Zona Oeste', 'Barra Funda', 'Estação Barra Funda', 'Observação da estação Barra Funda');

-- Primeiro INSERT
INSERT INTO extintores (
    Patrimonio, Tipo_ID, Capacidade_ID, Codigo_Fabricante, Data_Fabricacao, 
    Data_Validade, Ultima_Recarga, Proxima_Inspecao, ID_Localizacao, QR_Code, 
    Observacoes, Linha_ID, status_id
) VALUES (
    1001, 1, 3, 'FAB12345', '2023-05-15', 
    '2028-05-15', '2023-10-10', '2024-01-10', 2, 'QR1001ABC', 
    'Extintor próximo à entrada principal', 1, 1
);

-- Segundo INSERT
INSERT INTO extintores (
    Patrimonio, Tipo_ID, Capacidade_ID, Codigo_Fabricante, Data_Fabricacao, 
    Data_Validade, Ultima_Recarga, Proxima_Inspecao, ID_Localizacao, QR_Code, 
    Observacoes, Linha_ID, status_id
) VALUES (
    1002, 2, 2, 'FAB67890', '2022-03-20', 
    '2027-03-20', '2023-06-15', '2024-06-15', 5, 'QR1002DEF', 
    'Extintor localizado no corredor do segundo andar', 3, 2
);

-- Inserção corrigida no histórico de manutenção
INSERT INTO historico_manutencao (ID_Extintor, Data_Manutencao, Descricao, Responsavel_Manutencao, Observacoes) VALUES
(1001, '2023-06-15', 'Recarga realizada e inspeção visual', 'Carlos Silva', 'Revisado em todas as partes, sem problemas'),
(1002, '2023-06-16', 'Troca de válvula e recarga', 'Ana Costa', 'Válvulas trocadas, recarga completa'),
(1001, '2023-07-05', 'Verificação de pressão e recarga', 'Roberto Santos', 'Feito teste de pressão, aprovado'),
(1002, '2023-07-10', 'Inspeção de válvula', 'Juliana Oliveira', 'Inspeção completa sem defeitos');

-- Inserção de usuários
INSERT INTO usuarios (nome, email, senha, matricula, cargo_id) VALUES 
('Carlos Silva', 'carlos.silva@metrosp.com.br', 'senha123', 'MTR001', 1), 
('Ana Oliveira', 'ana.oliveira@metrosp.com.br', 'senha123', 'MTR002', 2), 
('Roberto Souza', 'roberto.souza@metrosp.com.br', 'senha123', 'MTR003', 3), 
('Lucas Silva Barboza', 'lucas.silva@metrosp.com.br', 'senha123', 'MTR004', 3);

