# Views & Functions/Procedures

Alexandre e Makalister.

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

## Functions/Procedures

### 1. Mostrar qual o número de telefone de um funcionário de um banco. 

```
drop function banco.obter_telefone;

create or replace function banco.obter_telefone(
		in input_cpf numeric(11),
		out "Nome do Funcionário" varchar,
		out "Telefone" numeric(10)
	)
	language 'plpgsql' as 
	$$
	begin
		select 
			funcionario.nome,
			telefonefuncionario.telefone
			from banco.funcionario
				inner join banco.telefonefuncionario on telefonefuncionario.cpf = funcionario.cpf
			where funcionario.cpf = input_cpf
		into "Nome do Funcionário", "Telefone";
	end;
	$$;
	
select * from banco.obter_telefone('1')
```


### 2. Mostrar todas as contas e saldo em banco de um cliente selecionado.

```
drop function banco.get_contas;

select * from banco.clienteconta;

create or replace function banco.get_contas(in c_nome varchar) 
	returns table("Banco" varchar,
		"Número da Conta" numeric,
		"Número da Agência" numeric,
		"Código do Banco" numeric)
language plpgsql
as $$
begin
return query
  select 
  	banco.nome,
  	clienteconta.numeroconta,
	clienteconta.numeroagencia,
  	clienteconta.nire
	from banco.clienteconta
  inner join banco.banco on banco.nire = clienteconta.nire
  inner join banco.cliente on cliente.id = clienteconta.idcliente
  where cliente.nome = c_nome;
  return; 
end; $$

select * from banco.get_contas('Adriano Sales Neto');
```

### 3. Aumentar o salário de todos os funcionários dos bancos.

```
create or replace procedure aumentaSALARIO(
	   f_salario IN Funcionario.salario%TYPE)
language plpgsql
as $$
begin
  update Funcionario set salario = (Funcionario.salario + f_salario);
  return;
end; $$

call aumentaSALARIO(200);

select * from Funcionario;
```

### 4. Exibir último empréstimo feito por um cliente.

```
drop function banco.obter_emprestimo_mais_recente;

create or replace function 
	banco.obter_emprestimo_mais_recente(input_id numeric(9))
	returns table(
		"Nome" varchar(50), 
		"Valor" numeric(11,2),
		"Juros" numeric(5,3)) 
	language plpgsql as $$
	begin
	return query
		select
		cliente.nome,
		emprestimo.valor,
		emprestimo.taxajuros
		from banco.cliente
			join banco.realiza on cliente.id = realiza.idcliente
			join banco.emprestimo on realiza.idemprestimo = emprestimo.id
		where cliente.id = input_id and realiza.idemprestimo in (
			-- Obtém o último registro
			select max(idemprestimo) from banco.realiza 
			where realiza.idcliente = cliente.id
		); 
	return;
	end;
	$$;

select * from banco.obter_emprestimo_mais_recente('2');
```

### 5. Exibir o número de empréstimos que o cliente fez, caso haja algum.

```
drop function banco.verifica_tem_emprestimo;

create or replace function banco.verifica_tem_emprestimo(
	input_clienteid numeric)
  returns text
as
$$
   declare
      emprestimo banco.realiza%rowtype;
	  quantidade_emprestimo bigint;
	  mensagem varchar(100);
begin
	select into quantidade_emprestimo
		count(realiza.idcliente) 
			from banco.realiza 
		where realiza.idcliente = input_clienteid;
		
	mensagem := 'O cliente não fez nenhum empréstimo.';
	if (quantidade_emprestimo > 0) then
		mensagem := 'O cliente fez ' || quantidade_emprestimo || ' empréstimo(s).';
	end if;	
	
	return mensagem;
end;
$$ language plpgsql;

select * from banco.verifica_tem_emprestimo(2);
```



