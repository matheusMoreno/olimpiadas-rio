program olimpiadasRio;
(*Programa feito para guardar informações sobre os atletas de cada país das Olimpíadas 2016. Responsável: Matheus Moreno. Data: 14/07/2016*)

uses bci, crt, dos; {bci é minha biblioteca pessoal; dos é usado para apagar arquivos.}

type

	registro=record {Estrutura que guarda as informações de cada atleta.}
		nome:string;
		idade:integer;
		modalidade:string;
		medalha:string;
	end;

	regFile=file of registro; {Arquivo para cada país, guardando os atletas.}

	pPais=^regPais; {Ponteiro para a lista duplamente encadeada.}

	regPais=record {Estrutura para a lista duplamente encadeada.}
		anterior,proximo:pPais;
		arqPais:regFile;
		codPais:string[20];
		atletaAtual:registro; {Esse campo nos será útil na ordenação da tabela de atletas.}
		ouro,prata,bronze,total:integer; {Esses campos serão usados na tabela de medalhas.}
	end;



//******************************//



{Procedimento simples que exibe um cabeçalho estilístico no topo do programa.}
procedure cabecalho();

begin
	textColor(Cyan);
	write('   〇');
	textColor(8);
	write('〇');
	textColor(Red);
	write('〇');
	textColor(White);
	write('             JOGOS OLÍMPICOS RIO 2016             ');
	textColor(Cyan);
	write('〇');
	textColor(8);
	write('〇');
	textColor(Red);
	writeln('〇');
	textColor(Yellow);
	write('    〇');
	textColor(Green);
	write('〇 ');
	textColor(White);
	write('    Programa de Controle de Atletas e Medalhas    ');
	textColor(Yellow);
	write(' 〇');
	textColor(Green);
	writeln('〇');
	textColor(White);
	writeln;
end;



//******************************//



{Esse procedimento exibe os países abertos no momento. Ele é chamado pelo menu na hora de ver os atletas de um país.}
procedure exibirPaises(primeiro:pPais);

var
	atual:pPais;
	contador,tamanho:shortint;

begin
	{Vamos para o início da lista encadeada.}
	atual:=primeiro;
	contador:=0;
	repeat
		contador:=contador+1;
		{O procedimento escreve o nome de cada país, com um espaço de no mínimo 2 dígitos entre cada país.}
		write(atual^.codPais);
		tamanho:=length(atual^.codPais);
		repeat
			write(' ');
			tamanho:=tamanho+1;
		until (tamanho=22);
		atual:=atual^.proximo;
		{Caso muitos países estejam abertos ao mesmo tempo, é melhor pular uma linha para continuar a listagem.}
		if (contador=3) and (atual<>nil) then
		begin
			writeln;
			contador:=0;
		end;
	until (atual=nil);
	writeln;
end;



//******************************//



{A função menu serve para deixar o programa principal mais limpo. Ela exibe as funcionalidades do programa.}
function funMenu(primeiro:pPais):shortint;

begin
	{Caso a lista de países ativos não esteja vazia, ela é exibida no menu.}
	if (primeiro<>nil) then
	begin
		textColor(LightBlue);
		writeln('Países ativos no momento:');
		textColor(White);
		exibirPaises(primeiro);
		writeln;
	end;
	writeln('O que você deseja fazer?');
	writeln;
	writeln('[1] Abrir/criar/fechar arquivo de um país'); {LINHAS 157 A 354}
	writeln('[2] Excluir arquivo de um país inativo'); {LINHAS 355 A 403}
	writeln('[3] Registrar novo atleta a um país ativo'); {LINHAS 404 A 598}
	writeln('[4] Editar medalha de um atleta de um país ativo'); {LINHAS 599 A 654}
	writeln('[5] Remover atleta de um país ativo'); {LINHAS 655 A 726}
	writeln('[6] Pesquisar atleta em países ativos'); {LINHAS 727 A 786}
	writeln('[7] Exibir quadro de medalhas relativo aos países ativos'); {LINHAS 787 A 897}
	writeln('[8] Listar atletas de todos os países ativos'); {LINHAS 898 A 1023}
	writeln('[9] Sair do programa');
	writeln;
	funMenu:=receberInteiro('Opção escolhida: ',1,9);
end;



//******************************//



{Este pequeno procedimento é versátil: será usado em todos os procedimentos para exibir avisos.}
procedure informeMenu(corMens:integer; mens:string);

begin
	clrscr;
	{O procedimento cabecalho() é chamado para manter o cabeçalho no topo do programa.}
	cabecalho();
	{Por convenção, o vermelho será usado para erros e o verde para ações concluídas com sucesso.}
	textColor(corMens);
	writeln(mens);
	textColor(White);
	writeln;
end;



//******************************//



{Este procedimento é chamado quando o usuário deseja abrir o arquivo de um país.}
procedure abrirPais(var primeiro,ultimo:pPais);

var
	novo,atual,predecessor:pPais;
	nomePais:string[20];
	abrirArq:boolean;

begin
	{Antes de tudo, precisamos checar se o arquivo do país já está aberto, senão ele irá criar um ponteiro desnecessário.}
	abrirArq:=true;
	nomePais:=receberString('Que país você deseja abrir (ou criar)? (máx. 20 caracteres) ',3,20);
	nomePais:=upcase(nomePais);
	{Caso a lista de países ativos não esteja vazia, precisamos varrê-la.}
	if (primeiro<>nil) then
	begin
		atual:=primeiro;
		while (atual^.proximo<>nil) and (nomePais<>atual^.codPais) do
			atual:=atual^.proximo;
		{Caso não cheguemos ao fim da lista ou o nome esteja no fim dela, o país já está aberto. Não podemos prosseguir.}
		if (atual^.proximo<>nil) or (nomePais=atual^.codPais) then
			abrirArq:=false;
	end;
	{Se o país não estiver aberto, continuamos o processo de abrir/criar um arquivo.}
	if (abrirArq=true) then
	begin
		{Primeiro, declaramos um novo pointer e recebemos o nome (código) do país.}
		new(novo);
		novo^.codPais:=nomePais;
		{Para não haver problemas na hora de abrir/criar arquivos, usamos a caixa alta.}
		novo^.codPais:=upcase(novo^.codPais);
		{O procedimento de abrir arquivo binário da unit é case sensitive, então não podemos usá-lo.}
		assign(novo^.arqPais,novo^.codPais+'.dat');
		{$I-}
		reset(novo^.arqPais);
		{$I+}
		{Caso o arquivo não exista (ioresult=2), simplesmente criamos um novo.}
		if (ioresult=2) then
		begin
			rewrite(novo^.arqPais);
			informeMenu(LightGreen,'Arquivo do país criado com sucesso!');
		end
		else
			informeMenu(LightGreen,'Arquivo do país aberto com sucesso!');
		{Se não haja nenhum país aberto, ele é definido como o primeiro e o último país.}
		if (primeiro=nil) then
		begin
			primeiro:=novo;
			ultimo:=novo;
			novo^.anterior:=nil;
			novo^.proximo:=nil;
		end
		else
		begin
			{Checamos se ele é menor que todos os países já abertos. Se for o caso, ele se torna o novo primeiro.}
			if (novo^.codPais<primeiro^.codPais) then
			begin
				novo^.proximo:=primeiro;
				primeiro^.anterior:=novo;
				primeiro:=novo;
				primeiro^.anterior:=nil;
			end
			else
			begin
				{Similarmente, caso ele não seja menor, checamos se ele é maior que todos, para se tornar o novo último.}
				if (novo^.codPais>ultimo^.codPais) then
				begin
					ultimo^.proximo:=novo;
					novo^.anterior:=ultimo;
					ultimo:=novo;
					ultimo^.proximo:=nil;
				end
				else
				begin
					{Senão, passeamos pela lista procurando a posição do país, checando de arquivo em arquivo.}
					atual:=primeiro;
					{Assim que chegarmos no nome maior que o nome do país que o usuário inseriu, precisamos inserí-lo.}
					while (novo^.codPais>atual^.codPais) do
						atual:=atual^.proximo;
					{Precisamos voltar para o ponteiro anterior, e inserir o novo entre o anterior e o atual.}
					predecessor:=atual^.anterior;
					predecessor^.proximo:=novo;
					novo^.anterior:=predecessor;
					novo^.proximo:=atual;
					atual^.anterior:=novo;
				end;
			end;
		end;
	end
	else
		{Avisamos ao usuário se o país que ele tentou consultar já esteja aberto.}
		informeMenu(LightRed,'ERRO: O arquivo desse país já se encontra aberto.');
end;



//******************************//



{Este procedimento fecha o arquivo de um país ativo e o remove da lista.}
procedure fecharPais(var primeiro,ultimo:pPais);

var
	nomePais:string;
	auxiliar,atual:pPais;

begin
	{Caso não haja nenhum país ativo no momento, o procedimento dá erro e não continua.}
	if (primeiro=nil) then
		informeMenu(LightRed,'ERRO: Não há nenhum país aberto no momento.')
	else
	begin
		{Recebemos o nome do país ativo que o usuário deseja fechar.}
		nomePais:=receberString('Informe o nome do país ativo que você deseja fechar: ',3,20);
		nomePais:=upcase(nomePais);
		{Checamos se o nome é igual ao primeiro país da lista.}
		if (nomePais=primeiro^.codPais) then
		begin
			close(primeiro^.arqPais);
			auxiliar:=primeiro;
			{O novo primeiro país será o seguinte ponteiro (mesmo que seja nulo).}
			primeiro:=primeiro^.proximo;
			{Se a lista não tiver só um país, precisamos dar anular o anterior do novo primeiro país.}
			if (primeiro<>nil) then
				primeiro^.anterior:=nil;
			{Precisamos dar dispose no ponteiro que estávamos usando.}
			dispose(auxiliar);
			informeMenu(LightGreen,'Arquivo do país fechado com sucesso!');
		end
		else
		begin
			{Caso não seja menor que todos, checamos se ele é maior que todos.}
			if (nomePais=ultimo^.codPais) then
			begin
				close(ultimo^.arqPais);
				auxiliar:=ultimo;
				ultimo:=ultimo^.anterior;
				ultimo^.proximo:=nil;
				dispose(auxiliar);
				informeMenu(LightGreen,'Arquivo do país fechado com sucesso!');
			end
			else
			{Se ele não for nem o primeiro nem o último, checamos se o pais se encontra na lista.}
			begin
				atual:=primeiro;
				while (atual^.codPais<>nomePais) and (atual^.proximo<>nil) do
					atual:=atual^.proximo;
				{Se ele não for encontrado, avisamos ao usuário que esse país não encontra-se ativo no momento.}
				if (atual^.proximo=nil) then
					informeMenu(LightRed,'ERRO: Não há um país aberto com esse nome.')
				else
				{Senão, fechamos o arquivo e juntamos o anterior ao seguinte, fechando o buraco da lista.}
				begin
					close(atual^.arqPais);
					auxiliar:=atual^.anterior;
					auxiliar^.proximo:=atual^.proximo;
					auxiliar:=atual^.proximo;
					auxiliar^.anterior:=atual^.anterior;
					dispose(atual);
					informeMenu(LightGreen,'Arquivo do país fechado com sucesso!');
				end;
			end;
		end;
	end;
end;



//******************************//



{Este é o procedimento que é chamado quando o usuário escolhe a opção 1 no menu.}
procedure abrirFecharArq(var primeiro,ultimo:pPais);

var
	escolha:string[1];

begin
	{Perguntamos ao usuário se ele deseja abrir/criar um novo arquivo ou fechar um arquivo.}
	repeat
		escolha:=receberString('Você deseja abrir/criar ou fechar o arquivo de um país? (A/F) ',1,1);
		escolha:=upcase(escolha);
	until (escolha='A') or (escolha='F');
	{Dependendo da escolha do usuário, chamamos um dos procedimentos acima.}
	if (escolha='A') then
		abrirPais(primeiro,ultimo)
	else
		fecharPais(primeiro,ultimo);
end;



//******************************//



{Este procedimento exclui um país inativo (arquivo fechado, nome não se encontra na lista).}
procedure excluirArquivo(primeiro:pPais);

var
	nomePais:string[20];
	atual:pPais;
	delPais:regFile;
	apagarArq:boolean;

begin
	{Começamos declarando que é verdadeira a possibilidade de excluir o arquivo do país.}
	apagarArq:=true;
	nomePais:=receberString('Informe o nome do país que você deseja excluir: ',3,20);
	nomePais:=upcase(nomePais);
	{Então, precisamos checar se o pais que o usuário deseja excluir está ativo ou não.}
	if (primeiro<>nil) then
	begin
		atual:=primeiro;
		while (atual^.codPais<>nomePais) and (atual^.proximo<>nil) do
			atual:=atual^.proximo;
		{Se estiver ativo, não podemos prosseguir com a exclusão.}
		if (atual^.proximo<>nil) or (atual^.codPais=nomePais) then
			apagarArq:=false;
	end;
	{Caso o arquivo esteja fechado (ou não exista), entramos nesse if.}
	if (apagarArq=true) then
	begin
		assign(delPais,nomePais+'.dat');
		{$I-}
		erase(delPais);
		{$I+}
		{Se o arquivo não existir, ioresult=2. Avisamos ao usuário que o arquivo é inexistente.}
		if (ioresult=2) then
			informeMenu(LightRed,'ERRO: Um arquivo deste país não existe.')
		{Senão, excluimos com sucesso o arquivo.}
		else
			informeMenu(LightGreen,'Arquivo do país excluído com sucesso!');
	end
	{O else é apenas um aviso para o usuário de que o arquivo do país encontra-se aberto.}
	else
		informeMenu(LightRed,'ERRO: O arquivo deste país está em uso. Feche-o e tente novamente.');
end;



//******************************//



{Esta função nos será útil para checar se um país encontra-se aberto ou não.}
function paisAberto(primeiro:pPais;var atual:pPais):boolean;

var
	nomePais:string[20];

begin
	{Simplesmente pedimos ao usuário o nome do país e varremos a lista o procurando.}
	nomePais:=receberString('Informe o nome do país do atleta: ',3,20);
	nomePais:=upcase(nomePais);
	{A variável atual é chamada por referência para podermos saber a posição em que o procedimento parou.}
	atual:=primeiro;
	{Ele funciona de maneira igual a pesquisa do caso de abrir e excluir um país.}
	while (atual^.codPais<>nomePais) and (atual^.proximo<>nil) do
		atual:=atual^.proximo;
	{Se o país não estiver aberto, a função retornará como falsa.}
	if (atual^.proximo=nil) and (atual^.codPais<>nomePais) then
	begin
		informeMenu(LightRed,'ERRO: Não há um país aberto com esse nome.');
		paisAberto:=false;
	end
	else
		paisAberto:=true;
end;



//******************************//



{O procedimento abaixo recebe os dados de um atleta. Ele é chamado na função novoAtleta.}
procedure receberDados(var atleta:registro);

var
	medalha:shortint;

begin
	{Todas as informações são colocadas em caixa alta para não haver problemas na hora de pesquisas.}
	atleta.nome:=receberString('Insira o nome completo do atleta: ',1,40);	
	atleta.nome:=upcase(atleta.nome);
	atleta.idade:=receberInteiro('Qual é a idade do atleta? ',15,80);
	atleta.modalidade:=receberString('E em qual modalidade o atleta compete? ',3,25);
	atleta.modalidade:=upcase(atleta.modalidade);
	{Para a medalha, pedimos ao usuário um número de 1 a 4. Assim, não haverá erros de digitação.}
	repeat
		medalha:=receberInteiro('Ganhou uma medalha? (1. ouro, 2. prata, 3. bronze ou 4. nenhuma) ',1,4);
	until (medalha>0) and (medalha<5);
	case medalha of
		1: atleta.medalha:='OURO';
		2: atleta.medalha:='PRATA';
		3: atleta.medalha:='BRONZE';
		4: atleta.medalha:='NENHUMA';
	end;
end;



//******************************//



{Um dos procedimentos mais complicados do programa: inserir um atleta já ordenado no arquivo do país.}
procedure ordenarNoMeio(var arquivo:regFile; ordenado:registro; var posicaoOrdenado:integer);

var
	centro,inicio,fim:integer;
	auxiliarUm,auxiliarDois:registro;

begin
	{O procedimento funciona como uma busca binária. Ele primeiro pega o início e o fim do arquivo.}
	inicio:=0;
	fim:=filesize(arquivo);
	reset(arquivo);
	read(arquivo,auxiliarUm);
	{Caso o arquivo contenha só um nome e seja o mesmo que você esteja registrando, o procedimento não continua.}
	if (fim=1) and (auxiliarUm.nome=ordenado.nome) then
		informeMenu(LightRed,'ERRO: Um atleta com esse nome já está registrado neste país.')
	{Senão, começamos a busca binária adaptada.}
	else
	begin
		repeat
			{Primeiro, vamos até o meio do arquivo.}
			centro:=(inicio+fim) div 2;
			seek(arquivo,centro-1);
			{Lemos os dois auxiliares, os quais estão na parte central do arquivo.}
			read(arquivo,auxiliarUm);
			read(arquivo,auxiliarDois);
			{Se ambos forem maiores que o nome adicionado, a metade do arquivo torna-se o novo limite da busca.}
			if (auxiliarUm.nome>ordenado.nome) and (auxiliarDois.nome>ordenado.nome) then							
				fim:=centro
			{Senão, se ambos forem menores, a metade torna-se o novo início da busca.}
			else
			begin
				if (auxiliarUm.nome<ordenado.nome) and (auxiliarDois.nome<ordenado.nome) then
					inicio:=centro;
			end;
			{O programa não permite dois atletas com o mesmo nome no mesmo país. Se for o caso, temos um erro.}
			if (auxiliarUm.nome=ordenado.nome) or (auxiliarDois.nome=ordenado.nome) then
			begin
				informeMenu(LightRed,'ERRO: Um atleta com esse nome já está registrado neste país.');
				posicaoOrdenado:=-2;
			end;
		{Repetimos isso até encontrar a posição em que o nome se encontra ou o procedimento dar erro.}
		until ((auxiliarUm.nome<ordenado.nome) and (auxiliarDois.nome>ordenado.nome)) or (posicaoOrdenado=-2);
		{Sem erros, a posição do atleta no arquivo é passada por referência para o procedimento novoAtleta.}
		if (auxiliarUm.nome<ordenado.nome) and (auxiliarDois.nome>ordenado.nome) then
			posicaoOrdenado:=centro;
	end;
end;



//******************************//



{Procedimento chamado caso o usuário escolha a opção 3 no menu.}
procedure novoAtleta(primeiro:pPais);

var
	atual:pPais;
	ordenado,atleta,auxiliarUm:registro;
	posicaoOrdenado,contador:integer;

begin
	{Se não houver nenhum país aberto no momento, o procedimento já se encerra.}
	if (primeiro=nil) then
		informeMenu(LightRed,'ERRO: Não há nenhum país ativo no momento.')
	else
	begin
		{Chamamos a função paisAberto para conferir se o país do atleta está aberto.}
		if (paisAberto(primeiro,atual)=true) then
		begin
			{Primeiramente, declaramos a posição (impossível) -1 no arquivo.}
			posicaoOrdenado:=-1;
			receberDados(ordenado);
			reset(atual^.arqPais);
			{Se o arquivo estiver vazio, simplesmente incluimos o atleta.}
			if (eof(atual^.arqPais)) then
			begin
				write(atual^.arqPais,ordenado);
				informeMenu(LightGreen,'O atleta foi registrado com sucesso!');
			end
			{Senão, primeiro checamos se ele é menor que todos os nomes.}
			else
			begin
				read(atual^.arqPais,auxiliarUm);
				{Caso ele seja, sua posição no arquivo torna-se 0 (ou seja, o primeiro nome).}
				if (ordenado.nome<auxiliarUm.nome) then
					posicaoOrdenado:=0
				{Se não for o caso, vemos se ele é menor que todos. Primeiro, vamos ao fim do arquivo.}
				else
				begin
					seek(atual^.arqPais,(filesize(atual^.arqPais)-1));
					read(atual^.arqPais,auxiliarUm);
					{Se o nome for maior que o último, ele é maior que todos.}
					if (ordenado.nome>auxiliarUm.nome) then
					begin
						{Para inclui-lo, precisamos simplesmente escrevê-lo no fim do arquivo.}
						write(atual^.arqPais,ordenado);
						informeMenu(LightGreen,'O atleta foi registrado com sucesso!');
					end
					else
						{Caso ele fique entre o meio e o fim, chamamos a função especial declarada acima.}
						ordenarNoMeio(atual^.arqPais,ordenado,posicaoOrdenado);
				end;
			end;
			{Caso a variável de posição seja alterada para uma posição >-1, precisamos "empurrar" os outros nomes.}
			if (posicaoOrdenado>-1) then
			begin
				{Para isso, simplesmente copiamos cada atleta e "colamos" uma posição a frente dele mesmo.}
				for contador:=filesize(atual^.arqPais)-1 downto posicaoOrdenado do
				begin
					seek(atual^.arqPais,contador);
					read(atual^.arqPais,atleta);
					seek(atual^.arqPais,contador+1);
					write(atual^.arqPais,atleta);
				end;
				{No fim, teremos um atleta repetido, que será sobrescrito pelo novo registro.}
				seek(atual^.arqPais,posicaoOrdenado);
				write(atual^.arqPais,ordenado);
				informeMenu(LightGreen,'O atleta foi registrado com sucesso!');
			end;
			reset(atual^.arqPais);
		end;
	end;
end;



//******************************//



{Para editar a medalha de um atleta, chamamos esse procedimento simples.}
procedure editarMedalha(primeiro:pPais);

var
	atual:pPais;
	atleta:registro;
	nome:string;
	medalha:integer;

begin
	{Como sempre, precisamos checar se a lista não está vazia.}
	if (primeiro=nil) then
		informeMenu(LightRed,'ERRO: Não há nenhum país ativo no momento.')
	else
	begin
		{Novamente chamamos a função paisAberto para checar se o país desejado encontra-se ativo.}
		if (paisAberto(primeiro,atual)=true) then
		begin
			{Recebemos o nome do atleta que terá a medalha modificada.}
			nome:=receberString('Informe o nome COMPLETO do atleta: ',1,40);	
			nome:=upcase(nome);
			reset(atual^.arqPais);
			atleta.nome:='';
			{Passeamos pelo arquivo procurando o atleta com o nome inserido.}
			while (not eof(atual^.arqPais)) and (nome<>atleta.nome) do
				read(atual^.arqPais,atleta);
			{Caso cheguemos ao fim do arquivo e nome não for encontrado, o procedimento retorna um erro.}
			if (eof(atual^.arqPais)=true) and (nome<>atleta.nome) then
				informeMenu(LightRed,'ERRO: Não há um atleta com esse nome no país.')
			{Senão, alteramos a medalha, perguntando exatamente o que é perguntado na hora de registrar um atleta.}
			else
			begin
				repeat
					medalha:=receberInteiro('Que medalha o atleta ganhou? (1. ouro, 2. prata, 3. bronze ou 4. nenhuma) ',1,4);
				until (medalha>0) and (medalha<5);
				case medalha of
					1: atleta.medalha:='OURO';
					2: atleta.medalha:='PRATA';
					3: atleta.medalha:='BRONZE';
					4: atleta.medalha:='NENHUMA';
				end;
				{Voltamos uma posição no arquivo e atualizamos as informações do atleta.}
				seek(atual^.arqPais,(filepos(atual^.arqPais)-1));
				write(atual^.arqPais,atleta);
				informeMenu(LightGreen,'Medalha modificada com sucesso!');
			end;
		end;
	end;
end;



//******************************//



{O procedimento de excluir um atleta é semelhante ao procedimento de adicionar.}
procedure excluirAtleta(primeiro:pPais);

var
	nome:string[40];
	atleta,auxiliar:registro;
	atual:pPais;
	posicao,controle:integer;

begin
	{Checando se há algum país ativo...}
	if (primeiro=nil) then
		informeMenu(LightRed,'ERRO: Não há nenhum país ativo no momento.')
	else
	begin
		{...e conferindo se o país do atleta encontra-se aberto.}
		if (paisAberto(primeiro,atual)=true) then
		begin
			{Similarmente ao procedimento de alterar medalha, pedimos o nome completo do atleta...}
			nome:=receberString('Informe o nome COMPLETO do atleta: ',1,40);	
			nome:=upcase(nome);
			reset(atual^.arqPais);
			atleta.nome:='';
			posicao:=-1;
			{...e conferimos se ele está registrado, guardando nossa posição atual no arquivo.}
			while (not eof(atual^.arqPais)) and (nome<>atleta.nome) do
			begin
				read(atual^.arqPais,atleta);
				posicao:=posicao+1;
			end;
			{Caso ele não esteja registrado, avisamos ao usuário e encerramos o procedimento.}
			if (eof(atual^.arqPais)) and (nome<>atleta.nome) then
				informeMenu(LightRed,'ERRO: Não há um atleta com esse nome no país.')
			else
			{Senão, temos dois casos:}
			begin
				{Primeiro, se ele estiver em qualquer posição que não seja o fim do arquivo.}
				if (posicao<>(filesize(atual^.arqPais)-1)) then
				begin
					{O processo é o inverso da adição: copiamos um atleta e o escrevemos uma posição ATRÁS dele.}
					for controle:=posicao+1 to filesize(atual^.arqPais)-1 do
					begin
						seek(atual^.arqPais,controle);
						read(atual^.arqPais,auxiliar);
						seek(atual^.arqPais,controle-1);
						write(atual^.arqPais,auxiliar);
					end;
					{No fim do arquivo, teremos o último atleta duplicado. Truncamos o arquivo para resolver o problema.}
					seek(atual^.arqPais,(filesize(atual^.arqPais)-1));
					truncate(atual^.arqPais);
					reset(atual^.arqPais);
				end
				{O segundo caso é se ele já estiver no fim do arquivo.}
				else
				begin
					{Se esse for o caso, truncamos o arquivo sem precisar fazer o resto.}
					seek(atual^.arqPais,posicao);
					truncate(atual^.arqPais);
					reset(atual^.arqPais);
				end;
				informeMenu(LightGreen,'Atleta excluído com sucesso.');
			end;
		end;
	end;
end;



//******************************//



{O procedimento de procurar um atleta varre todos os países abertos e mostra todos os resultados possíveis.}
procedure pesquisarAtleta(primeiro:pPais);

var
	nome:string[40];
	atual:pPais;
	contador:integer;
	auxiliar:registro;

begin
	{Procedimento padrão: vemos se há um país ativo.}
	if (primeiro=nil) then
		informeMenu(LightRed,'ERRO: Não há nenhum país ativo no momento.')
	else
	begin
		{O contador é necessário para avisar ao usuário caso a pesquisa não retorne resultado.}
		contador:=0;
		{Começamos recebendo a pesquisa: pode ser um nome, parte de um nome ou sobrenome.}
		nome:=receberString('Insira que você deseja pesquisar (nome, sobrenome...): ',1,40);	
		nome:=upcase(nome);
		informeMenu(Yellow,'Resultado(s) da pesquisa: ');
		atual:=primeiro;
		{Então, começamos o processo de passear pelos arquivos dos países, indo a cada ponteiro.}
		while (atual<>nil) do
		begin
			reset(atual^.arqPais);
			{Enquanto não chegamos no fim do arquivo, lemos registro por registro.}
			while (not eof(atual^.arqPais)) do
			begin
				read(atual^.arqPais,auxiliar);
				{Se um dos nomes do registro conter a série de caracteres pesquisada (a função pos retorna x>0), escrevemos na tela.}
				if (pos(nome,auxiliar.nome)<>0) then
				begin
					writeln(auxiliar.nome,' (',auxiliar.idade,' anos)');
					writeln('País: ',atual^.codPais);
					writeln('Modalidade: ',auxiliar.modalidade);
					writeln('Medalha: ',auxiliar.medalha);
					writeln;
					contador:=contador+1;
				end;
			end;
			atual:=atual^.proximo;
		end;
		{Se o contador der 0 no fim, a pesquisa não resultou em nada.}
		if (contador=0) then
		begin
			textColor(LightRed);
			writeln('Sua pesquisa não obteve resultados!');
			textColor(White);
			writeln;
		end;
	end;
end;



//******************************//



{Este procedimento é um complemento ao exibirMedalhas. Ele ordena as medalhas por quantidade de ouros.}
procedure ordenarOuro(primeiro:pPais);

var
	atual,maior:pPais;
	tamanho:shortint;

begin
	{O procedimento é chamado após a quantidade de medalhas de cada país ter sido contada.}
	atual:=primeiro;
	{Declaramos que o primeiro país possui a maior quantidade de medalhas de ouro.}
	maior:=atual;
	{Então, começamos a passear pela lista.}
	while (atual^.proximo<>nil) do
	begin
		atual:=atual^.proximo;
		{Se a quantidade de medalhas de ouro de um país for maior que a do anterior, ele se torna o novo maior.}
		if (atual^.ouro>maior^.ouro) then
			maior:=atual;
	end;
	{Então, escrevemos as informações do país com o maior número de ouros.}
	while (maior^.ouro<>-1) do
	begin
		write(maior^.codPais);
		{Contamos o tamanho e adicionamos o espaço simplesmente por motivos estilísticos.}
		tamanho:=length(maior^.codPais);
		repeat
			write(' ');
			tamanho:=tamanho+1;
		until (tamanho=22);
		writeln(maior^.ouro:4,'  ',maior^.prata:5,'  ',maior^.bronze:6,'  ',maior^.total:5);
		{Depois de escritas as informações, colocamos que a quantidade de ouros do maior é -1, para pegar o próximo maior.}
		maior^.ouro:=-1;
		{Repetimos o processo inicial. Precisamos fazê-lo fora do while antes para ficar de acordo com a condição do while.}
		atual:=primeiro;
		maior:=atual;
		while (atual^.proximo<>nil) do
		begin
			atual:=atual^.proximo;
			if (atual^.ouro>maior^.ouro) then
				maior:=atual;
		end;
	end;
end;



//******************************//



{Procedimento de exibir o quadro de medalhas ordenado a partir da quantidade de medalhas de ouro.}
procedure exibirMedalhas(primeiro:pPais);

var
	tamanho:shortint;
	atual:pPais;
	auxiliar:registro;

begin
	{Checagem padrão de país aberto.}
	if (primeiro=nil) then
		informeMenu(LightRed,'ERRO: Não há nenhum país ativo no momento.')
	else
	begin
		informeMenu(Yellow,'País                  Ouro  Prata  Bronze  Total');
		atual:=primeiro;
		{Fazemos a primeira passagem na lista contando a quantidade de medalhas de cada país.}
		while (atual<>nil) do
		begin
			reset(atual^.arqPais);
			atual^.ouro:=0;
			atual^.prata:=0;
			atual^.bronze:=0;
			atual^.total:=0;
			{Lemos registro por registro e adicionamos uma medalha de acordo com as informações de cada atleta.}
			while (not eof(atual^.arqPais)) do
			begin
				read(atual^.arqPais,auxiliar);
				case auxiliar.medalha of
					'OURO': atual^.ouro:=atual^.ouro+1;
					'PRATA': atual^.prata:=atual^.prata+1;
					'BRONZE': atual^.bronze:=atual^.bronze+1;
				end;
			end;
			atual^.total:=(atual^.ouro)+(atual^.prata)+(atual^.bronze);
			{E seguimos para o ponteiro seguinte.}
			atual:=atual^.proximo;
		end;
		{Se houver apenas um país ativo, não precisamos ordená-lo. Apenas escrevemos suas informações.}
		if (primeiro^.proximo=nil) then
		begin
			write(primeiro^.codPais);
			tamanho:=length(primeiro^.codPais);
			repeat
				write(' ');
				tamanho:=tamanho+1;
			until (tamanho=22);
			writeln(primeiro^.ouro:4,'  ',primeiro^.prata:5,'  ',primeiro^.bronze:6,'  ',primeiro^.total:5);
		end
		{Senão, chamamos o procedimento acima.}
		else
			ordenarOuro(primeiro);
		writeln;
	end;
end;



//******************************//



{Este procedimento ordena os atletas por ordem alfabética. Utilizamos um merge sort para ordená-los.}
procedure ordenarMultiplos(primeiro:pPais);

var
	atual,menor:pPais;
	tamanho:shortint;

begin
	{Primeiro, vamos para o início da lista.}
	atual:=primeiro;
	while (atual<>nil) do
	begin
		{Resetamos o arquivo do país e pegamos o primeiro atleta do país, colocando-o na variável "atletaAtual".}
		reset(atual^.arqPais);
		if (not eof(atual^.arqPais)) then
			read(atual^.arqPais,atual^.atletaAtual)
		{Se o arquivo estiver vazio, colocamos como nome do atleta um caractere maior que todas as maiúsculas no ASCII.}
		else
			atual^.atletaAtual.nome:='z';
		atual:=atual^.proximo;
	end;
	{Então, fazemos um processo similar ao odenarOuro: voltamos ao início da lista...}
	atual:=primeiro;
	{...declaramos o primeiro país como o recipiente do atleta de menor nome...}
	menor:=primeiro;
	while (atual^.proximo<>nil) do
	begin
		atual:=atual^.proximo;
		{...e alteramos essa atribuição caso haja um país com um atleta de nome "menor".}
		if (atual^.atletaAtual.nome<menor^.atletaAtual.nome) then
			menor:=atual;
	end;
	{Enquanto todos os países não tiverem sido lidos, escrevemos as informações dos atletas, na ordem de menor ao maior.}
	while (menor^.atletaAtual.nome<>'z') do
	begin
		{Escrevemos o nome do país, o nome do atleta, sua idade e medalha, tudo devidamente formatado.}
		write(menor^.codPais);
		tamanho:=length(menor^.codPais);
		repeat
			write(' ');
			tamanho:=tamanho+1;
		until (tamanho=22);
		write(menor^.atletaAtual.nome);
		tamanho:=length(menor^.atletaAtual.nome);
		repeat
			write(' ');
			tamanho:=tamanho+1;
		until (tamanho=42);
		writeln(menor^.atletaAtual.idade:5,'  ',menor^.atletaAtual.medalha);
		{Depois de tudo feito, lemos o próximo atleta no arquivo do país, caso exista.}
		if (not eof(menor^.arqPais)) then
			read(menor^.arqPais,menor^.atletaAtual)
		{Senão, "anulamos" o país com a letra controle, assim como fizemos lá em cima.}
		else
			menor^.atletaAtual.nome:='z';
		{Então, repetimos o processo inicial, procurando o próximo menor nome e escrevendo-o.}
		atual:=primeiro;
		menor:=atual;
		while (atual^.proximo<>nil) do
		begin
			atual:=atual^.proximo;
			if (atual^.atletaAtual.nome<menor^.atletaAtual.nome) then
				menor:=atual;
		end;
	end;
end;



//******************************//



{Este procedimento exibe todos os atletas de todos os países ativos, em ordem alfabética.}
procedure exibirAtletas(primeiro:pPais);

var
	atleta:registro;
	tamanho:shortint;

begin
	{Novamente, se a lista estiver vazia, nem prosseguimos com o procedimento.}
	if (primeiro=nil) then
		informeMenu(LightRed,'ERRO: Não há nenhum país ativo no momento.')
	else
	begin
		{Colocamos o cabeçalho da tabela como se fosse um informe do menu.}
		informeMenu(Yellow,'País                  Atleta                                    Idade  Medalha');
		{Se só haver um país ativo, não precisamos ordenar nada. Só escrevemos cada atleta.}
		if (primeiro^.proximo=nil) then
		begin
			reset(primeiro^.arqPais);
			while (not eof(primeiro^.arqPais)) do
			begin
				read(primeiro^.arqPais,atleta);
				write(primeiro^.codPais);
				tamanho:=length(primeiro^.codPais);
				repeat
					write(' ');
					tamanho:=tamanho+1;
				until (tamanho=22);
				write(atleta.nome);
				tamanho:=length(atleta.nome);
				repeat
					write(' ');
					tamanho:=tamanho+1;
				until (tamanho=42);
				writeln(atleta.idade:5,'  ',atleta.medalha);
			end;
			writeln;
		end
		{Senão, chamamos o procedimento ordenarMultiplos acima.}
		else
		begin
			ordenarMultiplos(primeiro);
			writeln;
		end;
	end;
end;



//******************************//



{Por fim, esse pequeno procedimento fecha todos os países ativos no fim do programa.}
procedure fecharArquivos(primeiro:pPais);

var
	atual:pPais;

begin
	{Ele simplesmente passeia pela lista fechando cada país.}
	atual:=primeiro;
	repeat
		close(atual^.arqPais);
		atual:=atual^.proximo;
	until (atual=nil);
end;



{*************** Programa principal ***************}


var
	opcao:shortint;
	primeiro,ultimo:pPais;

begin
	{Limpamos a tela do terminal e zeramos os ponteiros que serão usados.}
	clrscr;
	primeiro:=nil;
	ultimo:=nil;
	cabecalho();
	repeat
		opcao:=funMenu(primeiro);
		case opcao of
			1: abrirFecharArq(primeiro,ultimo); {Abrir/criar/fechar o arquivo de um país}
			2: excluirArquivo(primeiro); {Excluir arquivo de um país inativo}
			3: novoAtleta(primeiro); {Adicionar atleta a um país ativo}
			4: editarMedalha(primeiro); {Editar medalha de um atleta de um país ativo}
			5: excluirAtleta(primeiro); {Remover atleta de um país ativo}
			6: pesquisarAtleta(primeiro); {Pesquisar atleta nos países ativos}
			7: exibirMedalhas(primeiro); {Exibir o quadro de medalha por ordem de medalhas de ouro}
			8: exibirAtletas(primeiro); {Exibir atletas de países ativos por ordem alfabética}
			9: writeln('Obrigado por usar o programa!'); {Mensagem de fim do programa}
		end;
	until (opcao=9);
	{Se o usuário não tiver feito, fechar os arquivos abertos.}
	if (primeiro<>nil) then
		fecharArquivos(primeiro);
	{Voltar com as configurações normais do terminal.}
	normVideo;
end.
