CREATE TABLE banco.Banco (
	nire NUMERIC(11), -- PK
	nome VARCHAR(50) NOT NULL,
	dataFundacao DATE NOT NULL,
	logradouro VARCHAR(40) NOT NULL,
	numeroRua NUMERIC(4) NOT NULL,
	bairro VARCHAR(30) NOT NULL,
	cidade VARCHAR(30) NOT NULL,
	estado CHAR(2) NOT NULL,
  CONSTRAINT Banco_pk PRIMARY KEY (nire)
);

CREATE TABLE banco.Cliente (
	id NUMERIC(9), -- PK
	nome VARCHAR(50) NOT NULL,
	dataNascimento DATE NOT NULL,
	logradouro VARCHAR(40) NOT NULL,
	numeroRua NUMERIC(4) NOT NULL,
	bairro VARCHAR(30) NOT NULL,
	cidade VARCHAR(30) NOT NULL,
	estado VARCHAR(2) NOT NULL,
  CONSTRAINT Cliente_pk PRIMARY KEY (id)
);

CREATE TABLE banco.TelefoneCliente (
	telefone NUMERIC(10), -- PK
	idCliente NUMERIC(9), -- PK references Cliente
  CONSTRAINT TelefoneCliente_pk PRIMARY KEY (telefone, idCliente),
  CONSTRAINT TelefoneCliente_fk FOREIGN KEY (idCliente) REFERENCES banco.Cliente(id)
);

CREATE TABLE banco.PessoaJuridica (
	idCliente NUMERIC(9), -- PK references Cliente
	cnpj NUMERIC(14) UNIQUE NOT NULL,
	nomeFantasia VARCHAR(20) UNIQUE NOT NULL,
  CONSTRAINT PessoaJuridica_pk PRIMARY KEY (idCliente),
  CONSTRAINT PessoaJuridica_fk FOREIGN KEY (idCliente) REFERENCES banco.Cliente(id)
);

CREATE TABLE banco.PessoaFisica (
	idCliente NUMERIC(9), -- PK references Cliente
	cpf NUMERIC(11) UNIQUE NOT NULL,
	estadoCivil VARCHAR(20) NOT NULL,
	sexo CHAR(1) NOT NULL,
	rg NUMERIC(7) UNIQUE NOT NULL,
  CONSTRAINT PessoaFisica_pk PRIMARY KEY (idCliente),
  CONSTRAINT PessoaFisica_fk FOREIGN KEY (idCliente) REFERENCES banco.Cliente(id),
  CONSTRAINT PessoaFisica_sexo_ck CHECK (UPPER(sexo) IN ('M', 'F')),
  CONSTRAINT PessoaFisica_estadoCivil_ck CHECK (LOWER(estadoCivil) IN ('solteiro', 'casado'))
);

CREATE TABLE banco.Emprestimo (
	id NUMERIC(11), -- PK
	valor NUMERIC(11,2) NOT NULL,
	taxaJuros NUMERIC(5,3) NOT NULL,
	valorRestante NUMERIC(11,2) NOT NULL,
	dataQuitacao TIMESTAMP,
  CONSTRAINT Emprestimo_pk PRIMARY KEY (id)
);

CREATE TABLE banco.Pagamento (
	id NUMERIC(11), -- PK
	idEmprestimo NUMERIC(11), -- PK references Emprestimo
	dataPagamento TIMESTAMP NOT NULL,
	valor NUMERIC(11,2) NOT NULL,
  CONSTRAINT Pagamento_pk PRIMARY KEY (id, idEmprestimo),
  CONSTRAINT Pagamento_fk FOREIGN KEY (idEmprestimo) REFERENCES banco.Emprestimo(id)
);

CREATE TABLE banco.Agencia (
	numero NUMERIC(6), -- PK
	nire NUMERIC(11), -- PK references Banco
	cpfGerente NUMERIC(11), -- references Funcionario
	logradouro VARCHAR(40) NOT NULL,
	numeroRua NUMERIC(4) NOT NULL,
	bairro VARCHAR(30) NOT NULL,
	cidade VARCHAR(30) NOT NULL,
	estado CHAR(2) NOT NULL,
  CONSTRAINT Agencia_pk PRIMARY KEY (numero, nire),
  CONSTRAINT Agencia_Banco_fk FOREIGN KEY (nire) REFERENCES banco.Banco(nire)
  --CONSTRAINT Agencia_cpfGerente_fk FOREIGN KEY (cpfGerente) REFERENCES Funcionario(cpf);
);

CREATE TABLE banco.Funcionario (
	cpf NUMERIC(11), -- PK
	numeroAgencia NUMERIC(6), -- references Agencia
	nire NUMERIC(11), -- references Agencia
	cpfSupervisor NUMERIC(11), -- references Funcionario
	dataInicio DATE NOT NULL,
	nome VARCHAR(50) NOT NULL,
	salario NUMERIC(11,2) NOT NULL,
  CONSTRAINT Funcionario_pk PRIMARY KEY (cpf),
  CONSTRAINT Funcionario_Agencia_fk FOREIGN KEY (numeroAgencia, nire) REFERENCES banco.Agencia(numero, nire),
  CONSTRAINT Funcionario_cpfSupervisor_fk FOREIGN KEY (cpfSupervisor) REFERENCES banco.Funcionario(cpf)
);

ALTER TABLE banco.Agencia ADD CONSTRAINT Agencia_cpfGerente_fk FOREIGN KEY (cpfGerente) REFERENCES banco.Funcionario(cpf);

CREATE TABLE banco.TelefoneAgencia (
	telefone NUMERIC(10), -- PK
	numeroAgencia NUMERIC(6), -- PK references Agencia
	nire NUMERIC(11), -- PK references Agencia
  CONSTRAINT TelefoneAgencia_pk PRIMARY KEY (telefone, numeroAgencia, nire),
  CONSTRAINT TelefoneAgencia_fk FOREIGN KEY (numeroAgencia, nire) REFERENCES banco.Agencia(numero, nire)
);

CREATE TABLE banco.TelefoneFuncionario (
	telefone NUMERIC(10), -- PK
	cpf NUMERIC(11), -- PK references Funcionario
  CONSTRAINT TelefoneFuncionario_pk PRIMARY KEY (telefone, cpf),
  CONSTRAINT TelefoneFuncionario_fk FOREIGN KEY (cpf) REFERENCES banco.Funcionario(cpf)
);

CREATE TABLE banco.Realiza (
	idCliente NUMERIC(9), -- PK references Cliente
	idEmprestimo NUMERIC(11), -- PK references Emprestimo
	cpfFuncionario NUMERIC(11), -- PK references Funcionario
	dataEmprestimo TIMESTAMP NOT NULL,
  CONSTRAINT Realiza_pk PRIMARY KEY (idCliente, idEmprestimo, cpfFuncionario),
  CONSTRAINT Realiza_Cliente_fk FOREIGN KEY (idCliente) REFERENCES banco.Cliente(id),
  CONSTRAINT Realiza_Emprestimo_fk FOREIGN KEY (idEmprestimo) REFERENCES banco.Emprestimo(id),
  CONSTRAINT Realiza_Funcionario_fk FOREIGN KEY (cpfFuncionario) REFERENCES banco.Funcionario(cpf)
);

CREATE TABLE banco.Conta (
	numero NUMERIC(6), -- PK
	numeroAgencia NUMERIC(6), -- PK references Agencia
	nire NUMERIC(11), -- PK references Agencia
	saldo NUMERIC(11,2) NOT NULL,
  CONSTRAINT Conta_pk PRIMARY KEY (numero, numeroAgencia, nire),
  CONSTRAINT Conta_fk FOREIGN KEY (numeroAgencia, nire) REFERENCES banco.Agencia(numero, nire)
);

CREATE TABLE banco.ContaCorrente (
	numeroConta NUMERIC(6), -- PK references Conta
	numeroAgencia NUMERIC(6), -- PK references Conta
	nire NUMERIC(11), -- PK references Conta
	limiteChequeEspecial NUMERIC(11,2) NOT NULL,
  CONSTRAINT ContaCorrente_pk PRIMARY KEY (numeroConta, numeroAgencia, nire),
  CONSTRAINT ContaCorrente_fk FOREIGN KEY (numeroConta, numeroAgencia, nire) REFERENCES banco.Conta(numero, numeroAgencia, nire)
);

CREATE TABLE banco.ContaPoupanca (
	numeroConta NUMERIC(6), -- PK references Conta
	numeroAgencia NUMERIC(6), -- PK references Conta
	nire NUMERIC(11), -- PK references Conta
	taxaJuros NUMERIC(5,3) NOT NULL,
  CONSTRAINT ContaPoupanca_pk PRIMARY KEY (numeroConta, numeroAgencia, nire),
  CONSTRAINT ContaPoupanca_fk FOREIGN KEY (numeroConta, numeroAgencia, nire) REFERENCES banco.Conta(numero, numeroAgencia, nire)
);

CREATE TABLE banco.ClienteConta (
	idCliente NUMERIC(9), -- PK references Cliente
	numeroConta NUMERIC(6), -- PK references Conta
	numeroAgencia NUMERIC(6), -- PK references Conta
	nire NUMERIC(11), -- PK references Conta
  CONSTRAINT ClienteConta_pk PRIMARY KEY (idCliente, numeroConta, numeroAgencia, nire),
  CONSTRAINT ClienteConta_Cliente_fk FOREIGN KEY (idCliente) REFERENCES banco.Cliente(id),
  CONSTRAINT ClienteConta_Conta_fk FOREIGN KEY (numeroConta, numeroAgencia, nire) REFERENCES banco.Conta(numero, numeroAgencia, nire)
);

CREATE TABLE banco.Servico (
	id NUMERIC(11), -- PK
	idCliente NUMERIC(9), -- PK references ClienteConta
	numeroConta NUMERIC(6), -- PK references ClienteConta
	numeroAgencia NUMERIC(6), -- PK references ClienteConta
	nire NUMERIC(11), -- PK -- references ClienteConta
	valor NUMERIC(11,2) NOT NULL,
	tipo VARCHAR(10) NOT NULL,
	dataServico TIMESTAMP NOT NULL,
  CONSTRAINT Servico_pk PRIMARY KEY (id, idCliente, numeroConta, numeroAgencia, nire),
  CONSTRAINT Servico_fk FOREIGN KEY (idCliente, numeroConta, numeroAgencia, nire) REFERENCES banco.ClienteConta(idCliente, numeroConta, numeroAgencia, nire)
);
