const fs = require('fs'); // Para manipular o sistema de arquivos
const mysql = require('mysql2');
const cors = require('cors');
const PDFDocument = require('pdfkit');
const express = require('express');
const bodyParser = require('body-parser');
const QRCode = require('qrcode');
const path = require('path');
const moment = require('moment');
const app = express();

// Configuração do banco de dados
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'imtdb',
    database: 'metro_sp',
});

db.connect((err) => {
    if (err) {
        console.error('Erro ao conectar ao banco de dados:', err);
        return;
    }
    console.log('Conectado ao banco de dados MySQL');
});

// Middleware
app.use(cors({
    origin: '*',
    methods: 'GET, POST, PUT, DELETE',
    allowedHeaders: 'Content-Type, Authorization',
}));
app.use(bodyParser.json());

// Certifique-se de que a pasta "uploads" exista
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir);
}

const gerarSalvarQRCode = async (patrimonio) => {
    // Gera um link único para o QR Code, que será redirecionado para a geração do PDF
    const qrCodeData = `http://10.0.2.2:3001/pdf/${patrimonio}`; // Link para o PDF
    const qrCodePath = `uploads/${patrimonio}-qrcode.png`;

    await QRCode.toFile(qrCodePath, qrCodeData);  // Gera o QR Code com a URL para o PDF
    return qrCodePath;
};

// Endpoint para registrar o extintor e gerar o QR Code
app.post('/registrar_extintor', async (req, res) => {
    const {
        patrimonio,
        tipo_id,
        capacidade_id ,
        codigo_fabricante,
        data_fabricacao,
        data_validade,
        ultima_recarga,
        proxima_inspecao,
        status,
        linha_id,
        id_localizacao,
        observacoes,
    } = req.body;

    try {
        // Formatar datas
        const dataFabricacao = moment(data_fabricacao, 'DD/MM/YYYY').format('YYYY-MM-DD');
        const dataValidade = moment(data_validade, 'DD/MM/YYYY').format('YYYY-MM-DD');
        const ultimaRecarga = moment(ultima_recarga, 'DD/MM/YYYY').format('YYYY-MM-DD');
        const proximaInspecao = moment(proxima_inspecao, 'DD/MM/YYYY').format('YYYY-MM-DD');

        // Gerar o QR Code
        const qrCodePath = await gerarSalvarQRCode(patrimonio);

        // Inserir no banco de dados
        const query = `
            INSERT INTO Extintores 
            (Patrimonio, Tipo_ID, capacidade_id , Codigo_Fabricante, Data_Fabricacao, Data_Validade, Ultima_Recarga, Proxima_Inspecao, status_id, Linha_ID, ID_Localizacao, QR_Code, Observacoes) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `;
        db.query(query, [
            patrimonio, tipo_id, capacidade_id , codigo_fabricante, dataFabricacao, dataValidade, ultimaRecarga, proximaInspecao, status, linha_id, id_localizacao, qrCodePath, observacoes,
        ], (err) => {
            if (err) {
                console.error('Erro ao inserir no banco de dados:', err);
                return res.status(500).json({ success: false, message: 'Erro ao registrar o extintor.' });
            }

            res.json({ success: true, qrCodeUrl: `http://10.0.2.2:3001/uploads/${patrimonio}-qrcode.png` });
        });
    } catch (err) {
        console.error('Erro ao processar registro:', err);
        res.status(500).json({ success: false, error: 'Erro ao registrar o extintor.' });
    }
});

// Endpoint para gerar o PDF
app.get('/pdf/:patrimonio', (req, res) => {
    const patrimonio = req.params.patrimonio;

    db.execute('SELECT * FROM extintores WHERE Patrimonio = ?', [patrimonio], async (err, results) => {
        if (err || results.length === 0) {
            return res.status(404).send('Extintor não encontrado.');
        }

        const data = results[0];

        // Buscar o nome do Tipo
        const [tipoResult] = await db.promise().query('SELECT tipo FROM tipos_extintores WHERE id = ?', [data.Tipo_ID]);
        const tipoNome = tipoResult.length > 0 ? tipoResult[0].tipo : 'Tipo não encontrado';

        // Buscar o nome do Status
        const [statusResult] = await db.promise().query('SELECT nome FROM status_extintor WHERE id = ?', [data.status_id]);
        const statusNome = statusResult.length > 0 ? statusResult[0].nome : 'Status não encontrado';

        // Buscar o nome da Linha
        const [linhaResult] = await db.promise().query('SELECT nome FROM linhas WHERE id = ?', [data.Linha_ID]);
        const linhaNome = linhaResult.length > 0 ? linhaResult[0].nome : 'Linha não encontrada';

        // Buscar a Localização
        const [localizacaoResult] = await db.promise().query('SELECT Area, Subarea, Local_Detalhado FROM localizacoes WHERE ID_Localizacao = ?', [data.ID_Localizacao]);
        const localizacaoNome = localizacaoResult.length > 0 ? `${localizacaoResult[0].Area}, ${localizacaoResult[0].Subarea}, ${localizacaoResult[0].Local_Detalhado}` : 'Localização não encontrada';

        // Formatar as datas usando Moment.js
        const dataFabricacaoFormatada = moment(data.Data_Fabricacao).format('DD/MM/YYYY');
        const dataValidadeFormatada = moment(data.Data_Validade).format('DD/MM/YYYY');
        const ultimaRecargaFormatada = moment(data.Ultima_Recarga).format('DD/MM/YYYY');
        const proximaInspecaoFormatada = moment(data.Proxima_Inspecao).format('DD/MM/YYYY');

        // Criar o PDF dinamicamente
        const doc = new PDFDocument();
        res.setHeader('Content-Type', 'application/pdf');
        doc.pipe(res);

        doc.fontSize(12)
            .text(`Patrimônio: ${data.Patrimonio}`)
            .text(`Tipo: ${tipoNome}`) // Exibir o nome do tipo
            .text(`Capacidade: ${data.Capacidade}`)
            .text(`Código Fabricante: ${data.Codigo_Fabricante}`)
            .text(`Data de Fabricação: ${dataFabricacaoFormatada}`) // Exibir a data formatada
            .text(`Data de Validade: ${dataValidadeFormatada}`) // Exibir a data formatada
            .text(`Última Recarga: ${ultimaRecargaFormatada}`) // Exibir a data formatada
            .text(`Próxima Inspeção: ${proximaInspecaoFormatada}`) // Exibir a data formatada
            .text(`Linha: ${linhaNome}`) // Exibir o nome da linha
            .text(`Localização: ${localizacaoNome}`) // Exibir o nome da localização
            .text(`Status: ${statusNome}`) // Exibir o nome do status
            .text(`Observações: ${data.Observacoes}`);

        doc.end();
    });
});

// Servir arquivos estáticos
app.use('/uploads', express.static(uploadsDir));

const atualizarStatusExtintor = async (idExtintor) => {
    try {
        // Recupera o extintor com base no ID
        const query = 'SELECT * FROM Extintores WHERE Patrimonio = ?';
        db.query(query, [idExtintor], (err, results) => {
            if (err) {
                console.error('Erro ao buscar extintor:', err);
                return;
            }

            const extintor = results[0];
            if (!extintor) {
                console.log('Extintor não encontrado');
                return;
            }

            let novoStatus;
            const dataAtual = new Date();

            // Verifica se o extintor está vencido
            if (new Date(extintor.Data_Validade) < dataAtual) {
                novoStatus = 'Vencido';
            }
            // Verifica se o extintor foi violado
            else if (extintor.Status === 'violado') {
                novoStatus = 'Violado';
            }
            // Caso contrário, considera o status como Ativo
            else {
                novoStatus = 'Ativo';
            }

            // Recupera o id do status a partir do nome
            const queryStatus = 'SELECT id FROM Status_Extintor WHERE nome = ?';
            db.query(queryStatus, [novoStatus], (err, statusResult) => {
                if (err) {
                    console.error('Erro ao buscar status:', err);
                    return;
                }

                if (statusResult.length === 0) {
                    console.log('Status não encontrado');
                    return;
                }

                const statusId = statusResult[0].id;

                // Atualiza o status do extintor no banco
                const updateQuery = 'UPDATE Extintores SET status_id = ? WHERE Patrimonio = ?';
                db.query(updateQuery, [statusId, idExtintor], (err, updateResult) => {
                    if (err) {
                        console.error('Erro ao atualizar o status do extintor:', err);
                        return;
                    }
                    console.log('Status do extintor atualizado para:', novoStatus);
                });
            });
        });
    } catch (err) {
        console.error('Erro ao atualizar o status:', err);
    }
};

app.get('/extintores', (req, res) => {
    const query = 'SELECT Patrimonio, Tipo_ID FROM Extintores';
    db.query(query, (err, results) => {
        if (err) {
            console.error('Erro ao buscar extintores: ' + err.stack);
            return res.status(500).json({ success: false, message: 'Erro ao buscar extintores' });
        }

        console.log('Resultados encontrados:', results); // Verifique se está retornando a capacidade
        res.status(200).json({ success: true, extintores: results });
    });
});


app.post('/salvar_manutencao', (req, res) => {
    const {
        patrimonio,          // Usando Patrimonio
        descricao,
        responsavel,
        observacoes,
        data_manutencao,
        ultima_recarga,
        proxima_inspecao,
        data_vencimento,
        revisar_status // Novo campo para revisão de status
    } = req.body;

    // Verificação para garantir que todos os campos obrigatórios estão presentes
    if (
        !patrimonio ||
        !descricao ||
        !responsavel ||
        !data_manutencao ||
        !ultima_recarga ||
        !proxima_inspecao ||
        !data_vencimento
    ) {
        return res.status(400).json({ success: false, message: 'Todos os campos são obrigatórios' });
    }

    // 1. Inserir a manutenção no histórico de manutenção
    const queryManutencao = `
        INSERT INTO Historico_Manutencao (ID_Extintor, Data_Manutencao, Descricao, Responsavel_Manutencao, Observacoes)
        VALUES (?, ?, ?, ?, ?)
    `;

    // Executar a consulta para salvar a manutenção
    db.query(queryManutencao, [
        patrimonio,                // Referência ao campo Patrimonio como ID_Extintor
        data_manutencao,
        descricao,
        responsavel,
        observacoes || '',  // Observações podem ser nulas
    ], (err, result) => {
        if (err) {
            console.error('Erro ao salvar manutenção: ' + err.stack);
            return res.status(500).json({ success: false, message: 'Erro ao salvar manutenção' });
        }

        // 2. Agora, atualizamos os dados na tabela Extintores com as novas informações
        const queryExtintores = `
            UPDATE Extintores
            SET Ultima_Recarga = ?, Proxima_Inspecao = ?, Data_Validade = ?
            WHERE Patrimonio = ?
        `;

        // Atualizar as informações do extintor
        db.query(queryExtintores, [
            ultima_recarga,
            proxima_inspecao,
            data_vencimento,
            patrimonio    // Usando Patrimonio aqui para atualizar o extintor correto
        ], (err2, result2) => {
            if (err2) {
                console.error('Erro ao atualizar extintores: ' + err2.stack);
                return res.status(500).json({ success: false, message: 'Erro ao atualizar extintores' });
            }

            // 3. Atualizar o status do extintor, se necessário
            if (revisar_status) {
                // Certifique-se de que o status "Ativo" existe na tabela Status_Extintor
                const queryStatus = `
                    SELECT id FROM Status_Extintor WHERE nome = 'Ativo'
                `;

                // Obter o ID do status 'Ativo'
                db.query(queryStatus, [], (err3, result3) => {
                    if (err3) {
                        console.error('Erro ao buscar status: ' + err3.stack);
                        return res.status(500).json({ success: false, message: 'Erro ao buscar status' });
                    }

                    if (result3.length > 0) {
                        const status_id = result3[0].id;

                        // Atualizar o status do extintor com o ID correto
                        const queryUpdateStatus = `
                            UPDATE Extintores
                            SET status_id = ?
                            WHERE Patrimonio = ?
                        `;

                        // Atualiza o status do extintor para 'Ativo'
                        db.query(queryUpdateStatus, [status_id, patrimonio], (err4, result4) => {
                            if (err4) {
                                console.error('Erro ao atualizar status do extintor: ' + err4.stack);
                                return res.status(500).json({ success: false, message: 'Erro ao atualizar status' });
                            }

                            // Se a manutenção, atualização do extintor e status forem bem-sucedidos
                            res.status(200).json({ success: true, message: 'Manutenção salva, dados atualizados e status alterado com sucesso!' });
                        });
                    } else {
                        // Se o status 'Ativo' não foi encontrado
                        console.error('Status "Ativo" não encontrado na tabela Status_Extintor');
                        return res.status(500).json({ success: false, message: 'Status "Ativo" não encontrado' });
                    }
                });
            } else {
                // Se não for necessário revisar o status, apenas finalize a operação
                res.status(200).json({ success: true, message: 'Manutenção salva e dados atualizados com sucesso!' });
            }
        });
    });
});

app.get('/capacidades', (req, res) => {
    const query = 'SELECT id, descricao FROM capacidades';  // Alterando para pegar tanto o 'id' quanto a 'descricao'
    db.query(query, (err, results) => {
        if (err) {
            console.error('Erro ao consultar capacidades:', err);
            return res.status(500).json({ success: false, message: 'Erro ao buscar capacidades' });
        }

        // Enviando os dados como esperado pelo frontend
        res.json({ success: true, data: results });
    });
});

app.post('/login', (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ success: false, message: 'Campos obrigatórios faltando' });
    }

    const query = `
        SELECT usuarios.id, usuarios.nome, cargos.nome AS cargo
        FROM usuarios
        JOIN cargos ON usuarios.cargo_id = cargos.id
        WHERE usuarios.email = ? AND usuarios.senha = ?`;

    db.query(query, [email, password], (err, results) => {
        if (err) {
            console.error('Erro ao consultar o banco de dados:', err);
            return res.status(500).json({ success: false, message: 'Erro no servidor' });
        }

        if (results.length === 0) {
            return res.status(401).json({ success: false, message: 'Email ou senha incorretos' });
        }

        // Retornar o nome do usuário e cargo
        const usuario = results[0];
        return res.json({ success: true, nome: usuario.nome, cargo: usuario.cargo });
    });
});

app.get('/usuario', (req, res) => {
    const email = req.query.email;

    if (!email) {
        return res.status(400).json({ success: false, message: 'Email é obrigatório' });
    }

    console.log(`Procurando usuário com email: ${email}`);  // Log para depuração

    const query = `
        SELECT usuarios.id, usuarios.nome, usuarios.matricula, cargos.nome AS cargo
        FROM usuarios
        JOIN cargos ON usuarios.cargo_id = cargos.id
        WHERE usuarios.email = ?`;

    db.query(query, [email], (err, results) => {
        if (err) {
            console.error('Erro ao consultar o banco de dados:', err);
            return res.status(500).json({ success: false, message: 'Erro no servidor' });
        }

        if (results.length === 0) {
            console.log('Usuário não encontrado');  // Log para depuração
            return res.status(404).json({ success: false, message: 'Usuário não encontrado' });
        }

        const usuario = results[0];
        console.log('Usuário encontrado:', usuario);  // Log para depuração

        res.json({
            success: true,
            nome: usuario.nome,
            matricula: usuario.matricula,
            cargo: usuario.cargo,
            id: usuario.id,
        });
    });
});

app.get('/status', (req, res) => {
    const query = 'SELECT id, nome FROM Status_Extintor';

    db.query(query, (err, results) => {
        if (err) {
            console.error('Erro ao consultar status:', err);
            return res.status(500).json({ success: false, message: 'Erro ao buscar status' });
        }

        res.json({ success: true, data: results });
    });
});

app.get('/tipos-extintores', (req, res) => {
    const query = 'SELECT id, tipo AS nome FROM Tipos_Extintores';

    db.query(query, (err, results) => {
        if (err) {
            console.error('Erro ao consultar tipos de extintores:', err);
            return res.status(500).json({ success: false, message: 'Erro ao buscar tipos de extintores' });
        }

        res.json({ success: true, data: results });
    });
});

app.get('/localizacoes', (req, res) => {
    const linhaId = req.query.linhaId;
    if (!linhaId) {
        return res.status(400).json({ success: false, message: 'Linha ID é obrigatório' });
    }

    const query = `
  SELECT 
    ID_Localizacao AS id, 
    Area AS nome, 
    Subarea AS subarea, 
    Local_Detalhado AS local_detalhado 
  FROM Localizacoes 
  WHERE Linha_ID = ?
`;

    db.query(query, [linhaId], (err, results) => {
        if (err) {
            console.error('Erro ao consultar localizações:', err);
            return res.status(500).json({ success: false, message: 'Erro ao buscar localizações' });
        }

        res.json({ success: true, data: results });
    });
});


app.get('/linhas', (req, res) => {
    const query = 'SELECT * FROM Linhas';

    db.query(query, (err, results) => {
        if (err) {
            console.error('Erro ao buscar linhas:', err);
            return res.status(500).json({ success: false, message: 'Erro ao buscar linhas' });
        }
        res.json({ success: true, data: results });
    });
});

app.get('/patrimonio', (req, res) => {
    const query = 'SELECT patrimonio FROM extintores';
    db.query(query, (err, results) => {
        if (err) {
            console.error('Erro na consulta SQL:', err);
            res.status(500).json({ success: false, message: 'Erro na consulta ao banco de dados' });
            return;
        }

        console.log('Patrimônios encontrados:', results);  // Adicione este log
        const patrimônios = results.map(row => row.patrimonio);
        res.json({
            success: true,
            patrimônios: patrimônios,
        });
    });
});

app.get('/extintor/:patrimonio', (req, res) => {
    const patrimonio = req.params.patrimonio;
    console.log(`Buscando extintor com patrimônio: ${patrimonio}`);  // Log para depuração
    const query = `
        SELECT 
            e.Patrimonio, 
            e.Capacidade, 
            e.Codigo_Fabricante, 
            e.Data_Fabricacao, 
            e.Data_Validade, 
            e.Ultima_Recarga, 
            e.Proxima_Inspecao, 
            e.QR_Code, 
            e.Observacoes AS Observacoes_Extintor,
            s.nome AS Status, 
            t.tipo AS Tipo, 
            l.Area AS Localizacao_Area, 
            l.Subarea AS Localizacao_Subarea, 
            l.Local_Detalhado AS Localizacao_Detalhada, 
            l.Observacoes AS Observacoes_Local,
            ln.nome AS Linha_Nome, 
            ln.codigo AS Linha_Codigo, 
            ln.descricao AS Linha_Descricao,
            hm.ID_Manutencao, 
            hm.Data_Manutencao, 
            hm.Descricao AS Manutencao_Descricao, 
            hm.Responsavel_Manutencao, 
            hm.Observacoes AS Manutencao_Observacoes
        FROM Extintores e
        JOIN Status_Extintor s ON e.status_id = s.id
        JOIN Tipos_Extintores t ON e.Tipo_ID = t.id
        JOIN Localizacoes l ON e.ID_Localizacao = l.ID_Localizacao
        LEFT JOIN Linhas ln ON e.Linha_ID = ln.id
        LEFT JOIN Historico_Manutencao hm ON e.Patrimonio = hm.ID_Extintor
        WHERE e.Patrimonio = ?
    `;
    db.query(query, [patrimonio], (err, results) => {
        if (err) {
            console.error('Erro ao buscar extintor:', err);
            return res.status(500).json({ success: false, message: 'Erro ao buscar extintor' });
        }

        if (results.length === 0) {
            return res.status(404).json({ success: false, message: 'Extintor não encontrado' });
        }

        console.log('Extintor encontrado:', results[0]);  // Log para ver o retorno
        res.status(200).json({ success: true, extintor: results[0] });
    });
});


const PORT = 3001;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});