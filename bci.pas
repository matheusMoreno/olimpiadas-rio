unit bci;
(*Biblioteca de rotinas aprendidas e utilizadas em Computação I (BCI: Biblioteca Computação I). Responsável: Matheus Moreno. Data: 23/05/2016*)

interface

{Funções que recebem inteiros, reais e strings com tratamento de erro.}
	function receberInteiro(mensInt:string; minInteiro,maxInteiro:integer):integer; {LINHA 23}
	function receberReal(mensReal:string; minReal,maxReal:real):real; {LINHA 59}
	function receberString(mensString:string; minString,maxString:integer):string; {LINHA 94}

{Funções diversas: confirmar uma ação.}
	function funConfirmar(mens:string):char; {LINHA 126}

{Procedimentos relacionados a arquivos.}
	procedure abrirArquivoBin(mens:string; var arquivo:file; var nomeExterno:string; extensao:string; minNome,maxNome:shortint); {LINHA 154}
	procedure abrirArquivoTxt(mens:string; var arquivo:text; var nomeExterno:string; extensao:string; minNome,maxNome:shortint); {LINHA 228}

//*************************************************************************************************//


implementation

(*Função de recebimento de um inteiro (com tratamento de erro).*)
function receberInteiro(mensInt:string; minInteiro,maxInteiro:integer):integer;

var
	erro:boolean;
	valInteiro:integer;

begin
	{A função se repete até que as condições necessárias sejam alcançadas.}
	repeat
	begin
		write(mensInt);
		{$I-} {Desligamos o tratamento automático de erros I/O}
		readln(valInteiro);
		{$I+}
		erro:=true;
		{A função testa para ver se o que foi recebido foi um inteiro dentro dos limites.}
		if ioresult<>0 then
			writeln('O valor inserido não é um número inteiro. Tente novamente.')
		else {Obs.: Um bug na última versão do fpc causa overflow no recebimento, logo, às vezes o programa guarda dados positivos como negativos}
			if (minInteiro>valInteiro) then
				writeln('O valor inserido está abaixo do limite. Tente novamente.')
			else
				if (maxInteiro<valInteiro) then
					writeln('O valor inserido está acima do limite. Tente novamente.')
				else
					erro:=false;
	end;
	until erro=false;
	receberInteiro:=valInteiro;
end;


//***************//


(*Função de recebimento de um real (com tratamento de erro).*)
function receberReal(mensReal:string; minReal,maxReal:real):real;

var
	erro:boolean;
	valReal:real;

begin
	{Similiar à função de recebimento de inteiros, porém com variáveis reais.}
	repeat
	begin
		write(mensReal);
		{$I-}
		readln(valReal);
		{$I+}
		erro:=true;
		if ioresult<>0 then
			writeln('O valor inserido não é um número real. Tente novamente.')
		else
			if (minReal>valReal) then
				writeln('O valor inserido está abaixo do limite. Tente novamente.')
			else
				if (maxReal<valReal) then
					writeln('O valor inserido está acima do limite. Tente novamente.')
				else
					erro:=false;
	end;
	until erro=false;
	receberReal:=valReal;
end;


//***************//


(*Função de recebimento de uma string.*)
function receberString(mensString:string; minString,maxString:integer):string;

var
	comprimento:integer;
	erro:boolean;
	valString:string;

begin
	{No caso da string, não há tratamento de erro do programa; apenas é incluído limites máximo e mínimo.}
	repeat
	begin
		erro:=true;
		write(mensString);
		readln(valString);
		comprimento:=length(valString);
		if (minString>comprimento) then
			writeln('A série de caracteres inserida está abaixo do limite. Tente novamente.')
		else
			if (maxString<comprimento) then
				writeln('A série de caracteres inserida está acima do limite. Tente novamente.')
			else
				erro:=false;
	end;
	until erro=false;
	receberString:=valString;
end;


//***************//


(*Função para confirmar uma ação.*)
{Para chamar essa função, é preciso definir um texto base com uma pergunta a ser respondida com sim ou não.}
function funConfirmar(mens:string):char;

var
	carac:char;

begin
	{Similar às funções de recebimentos de reais e inteiros, porém para aceitar somente os caracteres S ou N.}
	repeat
	begin
		write(mens,' (S/N) ');
		{$I-}
		readln(carac);
		{$I+}
		{O upcase é aplicado para que não haja confusão por parte do programa.}
		carac:=upcase(carac);
		if ((carac<>'S') and (carac<>'N')) or (ioresult<>0) then
			writeln('Opção inválida. Tente novamente.');
	end;
	until ((carac='S') or (carac='N')) and (ioresult=0);
	funConfirmar:=carac;
end;


//***************//


{Procedimento para abrir ou criar um arquivo binário no mesmo diretório do programa (com tratamento de erros básicos)}
procedure abrirArquivoBin(mens:string; var arquivo:file; var nomeExterno:string; extensao:string; minNome,maxNome:shortint);

var
	escolha:char;
	iniciarArq:boolean;
	codigoErro:integer;

begin
	iniciarArq:=true; {Essa variável testará se as condições necessárias para abrir o arquivo foram alcançadas}
	repeat
		repeat
			write(mens,' (A/C) '); {O programa pergunta ao usuário se ele quer abrir ou criar um novo arquivo}
			{$I-}
			readln(escolha);
			escolha:=upcase(escolha);
			{$I+}
			if ((escolha<>'A') and (escolha<>'C')) then
				writeln('Opção inválida. Tente novamente.');
		until (escolha='A') or (escolha='C');
		if (escolha='A') then {Se ele quiser abrir um arquivo, o procedimento procura o arquivo no diretório em que se encontra}
		begin
			nomeExterno:=receberString('Informe o nome do arquivo (sem sua extensão): ',minNome,maxNome);
			assign(arquivo,nomeExterno+extensao);
			{$I-}
			reset(arquivo);
			{$I+}
			codigoErro:=ioresult; {Para não perdermos o código de erro, ele é passado para uma variável}
			case codigoErro of
				2: {Tratamento de erro caso não haja um arquivo com esse nome}			
				begin
					writeln('Um arquivo com esse nome não existe.');
					iniciarArq:=false;
				end;
				5: {Tratamento de erro caso dê acesso negado}
				begin
					writeln('O arquivo está protegido e não pode ser acessado.');
					iniciarArq:=false;
				end;
				0: iniciarArq:=true; {Caso não haja nenhum erro, o programa abre o arquivo normalmente}
			else iniciarArq:=false;
			end;
		end
		else
		begin {Nesse caso, o usuário optou por criar um novo arquivo}
			nomeExterno:=receberString('Informe o nome do novo arquivo (sem sua extensão): ',minNome,maxNome);
			assign(arquivo,nomeExterno+extensao);
			{$I-}
			reset(arquivo);
			{$I+}
			if ioresult=0 then {Caso o arquivo já exista, o programa pergunta se o usuário quer apagá-lo e começar do zero}
			begin
				if funConfirmar('Um arquivo com esse nome já existe!! Deseja destrui-lo e começar do zero?')='S' then
				begin
					rewrite(arquivo);
					iniciarArq:=true;
				end
				else {Se o usuário não quiser apagar o arquivo, o procedimento se reinicia}
					iniciarArq:=false;
			end
			else
			begin {Se houver algum erro, significa que o arquivo não existe, ou está corrompido, etc., e será resetado}
				rewrite(arquivo);
				iniciarArq:=true;
			end;
		end;
	until (iniciarArq=true); {O procedimento só acaba quando o arquivo é aberto}
end;


//***************//


{Procedimento para abrir ou criar um arquivo texto no mesmo diretório do programa (com tratamento de erros básicos)}
procedure abrirArquivoTxt(mens:string; var arquivo:text; var nomeExterno:string; extensao:string; minNome,maxNome:shortint);

var
	escolha:char;
	iniciarArq:boolean;
	codigoErro:integer;

begin
	iniciarArq:=true; {Esse procedimento funciona similarmente ao anterior, mas envolvendo também o append}
	repeat
		repeat
			write(mens,' (A/C/P) '); {O programa pergunta ao usuário se ele quer abrir, criar ou acrescentar algo ao arquivo}
			{$I-}
			readln(escolha);
			escolha:=upcase(escolha);
			{$I+}
			if ((escolha<>'A') and (escolha<>'C') and (escolha<>'P')) then
				writeln('Opção inválida. Tente novamente.');
		until (escolha='A') or (escolha='C') or (escolha='P');
		if (escolha='A') or (escolha='P') then {Se ele quiser abrir um arquivo, o procedimento o procura}
		begin
			nomeExterno:=receberString('Informe o nome do arquivo (sem sua extensão): ',minNome,maxNome);
			assign(arquivo,nomeExterno+extensao);
			{$I-}
			reset(arquivo);
			{$I+}
			codigoErro:=ioresult; {Para não perdermos o código de erro, ele é passado para uma variável}
			case codigoErro of
				2: {Tratamento de erro caso não haja um arquivo com esse nome}			
				begin
					writeln('Um arquivo com esse nome não existe.');
					iniciarArq:=false;
				end;
				5: {Tratamento de erro caso o arquivo esteja protegido}
				begin
					writeln('O arquivo está protegido e não pode ser acessado.');
					iniciarArq:=false;
				end;
				0: iniciarArq:=true; {Caso não haja nenhum erro, o programa abre o arquivo normalmente}
			else iniciarArq:=false;
			end;
			if (escolha='P') and (iniciarArq=true) then
				append(arquivo);
		end
		else
		begin {Nesse caso, o usuário optou por criar um novo arquivo}
			nomeExterno:=receberString('Informe o nome do novo arquivo (sem sua extensão): ',minNome,maxNome);
			assign(arquivo,nomeExterno+extensao);
			{$I-}
			reset(arquivo);
			{$I+}
			if ioresult=0 then {Caso o arquivo já exista, o programa pergunta se o usuário quer apagá-lo e começar do zero}
			begin
				if funConfirmar('Um arquivo com esse nome já existe!! Deseja destrui-lo e começar do zero?')='S' then
				begin
					rewrite(arquivo);
					iniciarArq:=true;
				end
				else {Se o usuário não quiser apagar o arquivo, o procedimento se reinicia}
					iniciarArq:=false;
			end
			else
			begin {Se houver algum erro, significa que o arquivo não existe, ou está corrompido, etc., e será resetado}
				rewrite(arquivo);
				iniciarArq:=true;
			end;
		end;
	until (iniciarArq=true); {O procedimento só acaba quando o arquivo é aberto}
end;


//***************//

end.
