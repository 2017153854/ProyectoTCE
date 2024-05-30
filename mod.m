%--------------------------------------------
% Tecnologico de Costa Rica 
% Escuela de Ingenieria en Electronica
%
% Taller de Comunicaciones Electricas
% Profesor:Ing. Francisco Navarro Henriquez. M.Sc, MBA
%
% Proyecto: Modelado de un sistema RF con correccion y deteccion
% de errores para una aplicacion medica mediante un SoC
% nRF52832 Nordic Semiconductor
%
% Modulador (mod.m):
% Este bloque se encarga de tomar la informacion proveniente del
% codificador y aplicar la modulacion necesaria para transmitir a traves de
% la antena.
%--------------------------------------------


clear all;
close all;


%--------------------------------------------
% INICIO TIEMPO DE EJECUCION:
% El siguiente fragmento inicia el cronometro para medir el tiempo que dura la moduacion
%--------------------------------------------
tic;     %Se inicia el temporizador
%--------------------------------------------


n=10;


%Leer los simbolos a modular
simbolos_a_modular = textread('DataInMod.txt','%s','delimiter','\n');
n_filas = length(simbolos_a_modular);
n_columnas = length(simbolos_a_modular{1});
matriz_bits = zeros(n_filas, n_columnas);
for i = 1:n_filas
    simbolo_en_procesamiento = simbolos_a_modular{i};
    for j = 1:n_columnas
        matriz_bits(i,j) = str2double(simbolo_en_procesamiento(j));
    end
end
transp=matriz_bits';


% Definir prueba para todos los datos
%data=matriz_bits(1,:)
% Y prueba de todos los datos
%data=transp(:);


% Ejemplo con un solo dato
simbolo_de_prueba = [0 1 1 0 1 1 0 1 1]';
fs = 2.4*10^9;  %Frecuencia de sampleo
tb = 1/fs;   %Tiempo de bit
cant_muestras = 500;  %Cantidad de muestras
M = 4;   %Orden de la modulacion 
banda_guarda = 5*10^6; %Banda guarda


% Senal temporal en NRZ (Mensaje m(t))
bits = [];
for n = 1:1:length(simbolo_de_prueba)
   if simbolo_de_prueba(n) == 1
       nbit = ones(1, cant_muestras);   %Tren de pulsos para un 1
   else  
       nbit = zeros(1, cant_muestras);  %Tren de pulson para un 0
   end
   bits = [bits nbit];
end


% Vector de tiempo
t = tb/cant_muestras : tb/cant_muestras : cant_muestras*length(simbolo_de_prueba)*(tb/cant_muestras);


%Visualizacion del Mensaje m(t) en NRZ
plot(t,bits,'LineWidth',2);
grid on;
%axis([0 tb*length(data)/10  -0.5 1.5]); %Para todos los datos
axis([0 tb*length(simbolo_de_prueba)  -0.3 1.3]);     %Para un dato
ylabel('Amplitud/V');
xlabel('Tiempo/s');
title('Mensaje m(t) en NRZ');


%Senal modulada s(t) en GFSK
s_t_fsk=fskmod(simbolo_de_prueba, M, banda_guarda, cant_muestras, fs);
filtro_gaussiano = gausswin(cant_muestras, cant_muestras*0.5);
s_t_gfsk = conv(s_t_fsk, filtro_gaussiano);


%Visualizacion de la Senal s(t) modulada en FSK
t_fsk = tb/cant_muestras : tb : tb*length(s_t_fsk);
figure(2)
plot(t_fsk,s_t_fsk,'LineWidth',2);
grid on;
xlabel('Tiempo/s');
ylabel('Amplitud/V');
title('Senal s(t) modulada en FSK');


%Visualizacion de la Senal s(t) modulada en GFSK
t = tb/cant_muestras : tb : tb*length(s_t_gfsk);
figure(3)
plot(t, s_t_gfsk, 'LineWidth', 2);
grid on;
xlabel('Tiempo/s');
ylabel('Amplitud/V');
title('Senal s(t) modulada en GFSK');
%axis([0 10000*tb  -1.5 1.5]);% Para todos los datos


% Salvar datos modulados
fid = fopen('DataOutMod.txt', 'w');
dlmwrite('DataOutMod.txt', [t(:), real(s_t_gfsk(:))], ',')


%--------------------------------------------
% FIN TIEMPO DE EJECUCION:
% Aqui se contabiliza cuanto duro la modulacion
%--------------------------------------------
t_mod = toc;     %Se detiene el temporizador
fprintf('La modulacion duro %.4f segundos.\n', t_mod);

