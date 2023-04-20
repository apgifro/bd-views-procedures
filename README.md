# Views & Procedures

## Views

### 1. Quais os gerentes de cada agência de todos os bancos?

```
select * from banco.agencia;
select * from banco.banco;
select * from banco.funcionario;

create or replace view banco.agencias as
select 
	agencia.numero as "Agência",
	banco.nome as "Banco", 
	initcap(agencia.logradouro) as "Logradouro", 
	initcap(agencia.cidade) as "Cidade",
	agencia.estado as "Estado",
	funcionario.nome as "Nome do Gerente dessa Agência",
	telefoneagencia.telefone as "Telefone"
	from banco.banco
		join banco.agencia on banco.nire = agencia.nire
		join banco.funcionario on agencia.cpfgerente = funcionario.cpf
		join banco.telefoneagencia on agencia.numero = telefoneagencia.numeroagencia
	order by banco.nome;
	
select * from banco.agencias;
```

### 2. Quais, em ordem, os funcionários mais bem pagos de todos os bancos?

```
select * from banco.funcionario;

create or replace view banco.maiores_salarios as
select 
	banco.nome as "Banco",
	funcionario.nome as "Nome do Funcionário",
	funcionario.salario as "Salário"
	from banco.funcionario
		join banco.banco on banco.nire = funcionario.nire
	order by salario desc;
	
select * from banco.maiores_salarios;
```

### 3. Quais os clientes com saldo superior a R$ 50.000 em todos os bancos?

```
select * from banco.cliente;
select * from banco.clienteconta;
select * from banco.conta;

create or replace view banco.saldo_superior_a_50000 as
select
	banco.nome as "Banco",
	conta.numero as "Número da Conta",
	cliente.nome as "Nome do Cliente",
	conta.saldo as "Saldo"
	from banco.cliente
		join banco.clienteconta on clienteconta.idcliente = cliente.id
		join banco.conta on conta.numero = clienteconta.idcliente
		join banco.banco on banco.nire = conta.nire
	where saldo > 50000
	order by saldo desc;
	
select * from banco.saldo_superior_a_50000;
```
