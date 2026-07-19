import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

// ======================= MODELO DE TRANSAÇÃO =======================

enum TipoTransacao {
  deposito,
  retirada,
  guardado,
  pixEnviado,
  pixRecebido,
}

class Transacao {
  final TipoTransacao tipo;
  final double valor;
  final DateTime data;
  final String descricao;

  Transacao({
    required this.tipo,
    required this.valor,
    required this.data,
    required this.descricao,
  });

  bool get isEntrada =>
      tipo == TipoTransacao.deposito ||
      tipo == TipoTransacao.pixRecebido;

  IconData get icone {
    switch (tipo) {
      case TipoTransacao.deposito:
        return Icons.add_circle;
      case TipoTransacao.retirada:
        return Icons.money_off;
      case TipoTransacao.guardado:
        return Icons.savings;
      case TipoTransacao.pixEnviado:
        return Icons.arrow_upward;
      case TipoTransacao.pixRecebido:
        return Icons.arrow_downward;
    }
  }
}

// ======================= MODELO DE CONTA =======================

class Conta {
  String nome;
  String email; // também usado como chave Pix
  String senha;
  double saldo;
  double poupanca;
  IconData icone;
  List<Transacao> historico;

  Conta({
    required this.nome,
    required this.email,
    required this.senha,
    required this.saldo,
    required this.poupanca,
    this.icone = Icons.person,
    List<Transacao>? historico,
  }) : historico = historico ?? [];

  void registrarTransacao(
    TipoTransacao tipo,
    double valor,
    String descricao,
  ) {
    historico.insert(
      0,
      Transacao(
        tipo: tipo,
        valor: valor,
        data: DateTime.now(),
        descricao: descricao,
      ),
    );
  }
}

// "Banco de dados" em memória (some quando o app é reiniciado)
class BancoDeContas {
  static List<Conta> contas = [
    Conta(
      nome: 'João Victor',
      email: 'joao@nubak.com',
      senha: '123456',
      saldo: 1621.00,
      poupanca: 250.00,
    ),
  ];
}

// ======================= LOGIN =======================

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController senhaController =
      TextEditingController();

  bool senhaVisivel = false;
  String? mensagemErro;

  void fazerLogin() {
    final email = emailController.text.trim();
    final senha = senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      setState(() {
        mensagemErro = 'Preencha e-mail e senha';
      });
      return;
    }

    final contaEncontrada = BancoDeContas.contas.firstWhere(
      (conta) => conta.email == email && conta.senha == senha,
      orElse: () => Conta(
        nome: '',
        email: '',
        senha: '',
        saldo: 0,
        poupanca: 0,
      ),
    );

    if (contaEncontrada.email.isEmpty) {
      setState(() {
        mensagemErro = 'E-mail ou senha inválidos';
      });
      return;
    }

    setState(() {
      mensagemErro = null;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainPage(conta: contaEncontrada),
      ),
    );
  }

  void irParaCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance,
                size: 80,
                color: Colors.white,
              ),

              SizedBox(height: 10),

              Text(
                'Nubak',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 40),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        keyboardType:
                            TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      SizedBox(height: 15),

                      TextField(
                        controller: senhaController,
                        obscureText: !senhaVisivel,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              senhaVisivel
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                senhaVisivel = !senhaVisivel;
                              });
                            },
                          ),
                        ),
                      ),

                      if (mensagemErro != null) ...[
                        SizedBox(height: 10),
                        Text(
                          mensagemErro!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ],

                      SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                          ),
                          onPressed: fazerLogin,
                          child: Text(
                            'Entrar',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      TextButton(
                        onPressed: irParaCadastro,
                        child: Text('Criar uma conta'),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 15),

              Text(
                'Use joao@nubak.com / 123456 para testar',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================= CADASTRO =======================

class CadastroPage extends StatefulWidget {
  const CadastroPage({Key? key}) : super(key: key);

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final TextEditingController nomeController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController senhaController =
      TextEditingController();

  String? mensagemErro;

  void criarConta() {
    final nome = nomeController.text.trim();
    final email = emailController.text.trim();
    final senha = senhaController.text.trim();

    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      setState(() {
        mensagemErro = 'Preencha todos os campos';
      });
      return;
    }

    final jaExiste = BancoDeContas.contas.any(
      (conta) => conta.email == email,
    );

    if (jaExiste) {
      setState(() {
        mensagemErro = 'Já existe uma conta com esse e-mail';
      });
      return;
    }

    // Gera valores diversificados para cada nova conta
    final random = Random();

    double saldoInicial =
        100 + random.nextInt(4900) + random.nextDouble();

    double poupancaInicial =
        random.nextInt(1000) + random.nextDouble();

    saldoInicial = double.parse(saldoInicial.toStringAsFixed(2));
    poupancaInicial =
        double.parse(poupancaInicial.toStringAsFixed(2));

    final novaConta = Conta(
      nome: nome,
      email: email,
      senha: senha,
      saldo: saldoInicial,
      poupanca: poupancaInicial,
    );

    BancoDeContas.contas.add(novaConta);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Conta criada!'),
          content: Text(
            'Sua conta foi criada com sucesso.\n\n'
            'Chave Pix: $email\n'
            'Saldo inicial: R\$ ${saldoInicial.toStringAsFixed(2)}\n'
            'Poupança inicial: R\$ ${poupancaInicial.toStringAsFixed(2)}',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // fecha o dialog

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainPage(conta: novaConta),
                  ),
                );
              },
              child: Text('Entrar na conta'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar conta'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(
                labelText: 'Nome completo',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 15),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'E-mail (será sua chave Pix)',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 15),

            TextField(
              controller: senhaController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Senha',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),

            if (mensagemErro != null) ...[
              SizedBox(height: 10),
              Text(
                mensagemErro!,
                style: TextStyle(color: Colors.red),
              ),
            ],

            SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: criarConta,
                child: Text(
                  'Criar conta',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= APP PRINCIPAL =======================

class MainPage extends StatefulWidget {
  final Conta conta;

  const MainPage({Key? key, required this.conta}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int paginaAtual = 0;
  late Conta conta;

  @override
  void initState() {
    super.initState();
    conta = widget.conta;
  }

  void atualizarSaldo(double novoSaldo, double novaPoupanca) {
    setState(() {
      conta.saldo = novoSaldo;
      conta.poupanca = novaPoupanca;
    });
  }

  void atualizarPerfil(String novoNome, IconData novoIcone) {
    setState(() {
      conta.nome = novoNome;
      conta.icone = novoIcone;
    });
  }

  @override
  Widget build(BuildContext context) {
    final paginas = [
      HomePage(
        nome: conta.nome,
        saldo: conta.saldo,
        poupanca: conta.poupanca,
      ),
      PixPage(
        conta: conta,
        onAtualizarSaldo: atualizarSaldo,
      ),
      HistoricoPage(conta: conta),
      PerfilPage(
        conta: conta,
        onAtualizar: atualizarPerfil,
      ),
    ];

    return Scaffold(
      body: paginas[paginaAtual],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: paginaAtual,
        selectedItemColor: Colors.purple,
        onTap: (index) {
          setState(() {
            paginaAtual = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pix),
            label: 'Pix',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Extrato',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String nome;
  final double saldo;
  final double poupanca;

  const HomePage({
    Key? key,
    required this.nome,
    required this.saldo,
    required this.poupanca,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool mostrarSaldo = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        toolbarHeight: 90,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black,
            child: Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
        ),
        title: Text('Olá, ${widget.nome}'),
        actions: [
          IconButton(
            icon: Icon(
              mostrarSaldo
                  ? Icons.visibility
                  : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                mostrarSaldo = !mostrarSaldo;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.verified_user),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              title: Text('Saldo em conta'),
              subtitle: Text(
                mostrarSaldo
                    ? 'R\$ ${widget.saldo.toStringAsFixed(2)}'
                    : '••••••',
                style: TextStyle(fontSize: 24),
              ),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          SizedBox(height: 15),
          Card(
            child: ListTile(
              title: Text('Poupança'),
              subtitle: Text(
                mostrarSaldo
                    ? 'R\$ ${widget.poupanca.toStringAsFixed(2)}'
                    : '••••••',
                style: TextStyle(fontSize: 22),
              ),
              trailing: Icon(Icons.savings),
            ),
          ),
        ],
      ),
    );
  }
}

class PixPage extends StatefulWidget {
  final Conta conta;
  final Function(double, double) onAtualizarSaldo;

  const PixPage({
    Key? key,
    required this.conta,
    required this.onAtualizarSaldo,
  }) : super(key: key);

  @override
  State<PixPage> createState() => _PixPageState();
}

class _PixPageState extends State<PixPage> {
  late double saldoGlobal;
  late double poupancaGlobal;

  final TextEditingController valorController =
      TextEditingController();

  final TextEditingController chavePixController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    saldoGlobal = widget.conta.saldo;
    poupancaGlobal = widget.conta.poupanca;
  }

  double? pegarValor() {
    return double.tryParse(valorController.text);
  }

  void adicionarSaldo() {
    double? valor = pegarValor();
    if (valor == null || valor <= 0) {
      return;
    }

    setState(() {
      saldoGlobal += valor;
    });

    widget.conta.registrarTransacao(
      TipoTransacao.deposito,
      valor,
      'Depósito em conta',
    );

    widget.onAtualizarSaldo(saldoGlobal, poupancaGlobal);
    valorController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saldo adicionado com sucesso')),
    );
  }

  void retirar() {
    double? valor = pegarValor();

    if (valor == null || valor <= 0 || valor > saldoGlobal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saldo insuficiente')),
      );
      return;
    }

    setState(() {
      saldoGlobal -= valor;
    });

    widget.conta.registrarTransacao(
      TipoTransacao.retirada,
      valor,
      'Retirada em dinheiro',
    );

    widget.onAtualizarSaldo(saldoGlobal, poupancaGlobal);
    valorController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Retirada realizada com sucesso')),
    );
  }

  void guardarValor() {
    double? valor = pegarValor();

    if (valor == null || valor <= 0 || valor > saldoGlobal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saldo insuficiente')),
      );
      return;
    }

    setState(() {
      saldoGlobal -= valor;
      poupancaGlobal += valor;
    });

    widget.conta.registrarTransacao(
      TipoTransacao.guardado,
      valor,
      'Valor guardado na poupança',
    );

    widget.onAtualizarSaldo(saldoGlobal, poupancaGlobal);
    valorController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Valor guardado com sucesso')),
    );
  }

  void transferirViaPix() {
    final chaveDestino = chavePixController.text.trim();
    double? valor = pegarValor();

    if (chaveDestino.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Digite a chave Pix do destinatário'),
        ),
      );
      return;
    }

    if (valor == null || valor <= 0 || valor > saldoGlobal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Valor inválido ou saldo insuficiente')),
      );
      return;
    }

    if (chaveDestino == widget.conta.email) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Você não pode transferir para você mesmo'),
        ),
      );
      return;
    }

    final index = BancoDeContas.contas.indexWhere(
      (conta) => conta.email == chaveDestino,
    );

    if (index == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chave Pix não encontrada')),
      );
      return;
    }

    final contaDestino = BancoDeContas.contas[index];

    setState(() {
      saldoGlobal -= valor;
      contaDestino.saldo += valor;
    });

    widget.conta.registrarTransacao(
      TipoTransacao.pixEnviado,
      valor,
      'Pix enviado para ${contaDestino.nome}',
    );

    contaDestino.registrarTransacao(
      TipoTransacao.pixRecebido,
      valor,
      'Pix recebido de ${widget.conta.nome}',
    );

    widget.onAtualizarSaldo(saldoGlobal, poupancaGlobal);

    chavePixController.clear();
    valorController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pix enviado para ${contaDestino.nome} com sucesso!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Área Pix'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sua chave Pix',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(widget.conta.email),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            Text('Saldo atual', style: TextStyle(fontSize: 18)),
            SizedBox(height: 5),
            Text(
              'R\$ ${saldoGlobal.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 30),

            TextField(
              controller: valorController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Digite um valor',
                border: OutlineInputBorder(),
                prefixText: 'R\$ ',
              ),
            ),

            SizedBox(height: 25),

            ElevatedButton.icon(
              onPressed: adicionarSaldo,
              icon: Icon(Icons.add),
              label: Text('Adicionar saldo'),
            ),

            SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: retirar,
              icon: Icon(Icons.money_off),
              label: Text('Retirar'),
            ),

            SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: guardarValor,
              icon: Icon(Icons.savings),
              label: Text('Guardar'),
            ),

            SizedBox(height: 30),

            Divider(),

            SizedBox(height: 10),

            Text(
              'Transferir via Pix',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 15),

            TextField(
              controller: chavePixController,
              decoration: InputDecoration(
                labelText: 'Chave Pix do destinatário',
                prefixIcon: Icon(Icons.key),
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: transferirViaPix,
              icon: Icon(Icons.send),
              label: Text('Enviar via Pix'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= HISTÓRICO / EXTRATO =======================

class HistoricoPage extends StatelessWidget {
  final Conta conta;

  const HistoricoPage({Key? key, required this.conta}) : super(key: key);

  String formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return '$dia/$mes às $hora:$minuto';
  }

  String tituloTransacao(TipoTransacao tipo) {
    switch (tipo) {
      case TipoTransacao.deposito:
        return 'Depósito';
      case TipoTransacao.retirada:
        return 'Retirada';
      case TipoTransacao.guardado:
        return 'Guardado na poupança';
      case TipoTransacao.pixEnviado:
        return 'Pix enviado';
      case TipoTransacao.pixRecebido:
        return 'Pix recebido';
    }
  }

  @override
  Widget build(BuildContext context) {
    final transacoes = conta.historico;

    return Scaffold(
      appBar: AppBar(
        title: Text('Extrato'),
        backgroundColor: Colors.purple,
      ),
      body: transacoes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Nenhuma transação ainda',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.all(15),
              itemCount: transacoes.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1),
              itemBuilder: (context, index) {
                final transacao = transacoes[index];
                final cor = transacao.isEntrada
                    ? Colors.green
                    : Colors.red;

                final sinal = transacao.isEntrada ? '+' : '-';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cor.withOpacity(0.15),
                    child: Icon(transacao.icone, color: cor),
                  ),
                  title: Text(tituloTransacao(transacao.tipo)),
                  subtitle: Text(
                    '${transacao.descricao}\n${formatarData(transacao.data)}',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    '$sinal R\$ ${transacao.valor.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: cor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class PerfilPage extends StatelessWidget {
  final Conta conta;
  final Function(String, IconData) onAtualizar;

  const PerfilPage({
    Key? key,
    required this.conta,
    required this.onAtualizar,
  }) : super(key: key);

  void editarPerfil(BuildContext context) {
    TextEditingController nomeController = TextEditingController(
      text: conta.nome,
    );

    IconData iconeSelecionado = conta.icone;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Editar Perfil'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nomeController,
                    decoration: InputDecoration(
                      labelText: 'Novo nome',
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Escolha uma foto'),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                    children: [
                      Icons.person,
                      Icons.face,
                      Icons.account_circle,
                      Icons.sentiment_satisfied,
                    ].map((icone) {
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            iconeSelecionado = icone;
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor:
                              iconeSelecionado == icone
                                  ? Colors.purple
                                  : null,
                          child: Icon(
                            icone,
                            color: iconeSelecionado == icone
                                ? Colors.white
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    onAtualizar(
                      nomeController.text.trim().isEmpty
                          ? conta.nome
                          : nomeController.text.trim(),
                      iconeSelecionado,
                    );
                    Navigator.pop(context);
                  },
                  child: Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void sair(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => sair(context),
            tooltip: 'Sair',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () => editarPerfil(context),
        child: Icon(Icons.edit),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Icon(
                conta.icone,
                size: 50,
              ),
            ),
            SizedBox(height: 20),
            Text(
              conta.nome,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              conta.email,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Conta Nubak',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => sair(context),
              icon: Icon(Icons.logout),
              label: Text('Sair da conta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}