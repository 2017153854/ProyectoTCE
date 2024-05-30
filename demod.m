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
% Demodulador (demod.m):
% Este bloque se encarga de tomar la informacion proveniente de la
% antena y aplicar la demodulacion necesaria para poder ser decodificada.
%--------------------------------------------


clear all;
close all;


n=10;


% MODULACION DE PRUEBA
% Parametros
data= [0 1 1 0 1 1 0 1 1]';
fs=2.4*10^9; 
tb=1/fs;
cant_muestras=500; 
M=4;     
banda_guarda=5*10^6;

%Senal NRZ
bits = [];  
for n = 1:1:length(data)
   if data(n) == 1
       nuevo_bit = ones(1, cant_muestras);
   else 
       nuevo_bit = zeros(1, cant_muestras);
   end
   bits = [bits nuevo_bit];
end

%Modulacion GFSK
s_t_fsk=fskmod(data, M, banda_guarda, cant_muestras, fs);
filtro_gaussiano = gausswin(cant_muestras, cant_muestras*0.5);
s_t_gfsk = conv(s_t_fsk, filtro_gaussiano);

% Visualizar senal modulada entrante
t = tb/cant_muestras : tb : tb*length(s_t_gfsk);
figure(2)
plot(t, s_t_gfsk, 'LineWidth', 2, 'Color', 'r');
grid on;
xlabel('Tiempo/s');
ylabel('Amplitud/V');
title('Senal Recibida por la Antena');






% /////////////////////////
% INICIO DE LA DEMODULACION
% \\\\\\\\\\\\\\\\\\\\\\\\\


%--------------------------------------------
% INICIO TIEMPO DE EJECUCION:
% El siguiente fragmento inicia el cronometro para medir el tiempo que dura la moduacion
%--------------------------------------------
tic;     %Se inicia el temporizador
%--------------------------------------------


% ACONDICIONAMIENTO DE LA SENAL
%PINN_gfsk=find(s_t_gfsk,1); % PINN: Primer Indice No Nulo
%s_t_gfsk_sin_cero = s_t_gfsk(PINN_gfsk:end); % Nueva señal gfsk
%PINN_filtro=find(filter,1); % Primer índice no nulo del filtro gaussiano
%filtro_gausseano_sin_cero=filter(PINN_filtro:end); % Nuevo filtro


% FILTRADO
s_t_gfsk=[0; s_t_gfsk]; % Añade cero al inicio para la sincronizaciOn
senconv=conv(s_t_gfsk, filtro_gaussiano, 'same');


% VISUALIZACION DEL FILTRADO
t = tb/cant_muestras : tb : tb*length(senconv);
figure(3) 
plot(t, senconv, 'LineWidth', 2, 'Color', 'r');
grid on;


% DEMODULACION: FREQUENCY SHIFT KEYING
s_t_demod = fskdemod(senconv, M, banda_guarda, cant_muestras, fs);
bits_demod=[];
for k=1 : 1 : length(s_t_demod)
   if s_t_demod(k) == 1
       bit_recibido = ones(1, cant_muestras);   %Tren de pulsos para un 1
   else 
       bit_recibido = zeros(1, cant_muestras);  %Tren de pulsos para un 0
   end
   bits_demod = [bits_demod bit_recibido];
end


% VISUALIZACION DE LA DEMODULACION
t_demod = tb/cant_muestras : tb/cant_muestras : cant_muestras*length(s_t_demod)*(tb/cant_muestras);
plot(t_demod, bits_demod, 'LineWidth', 2, 'Color', 'r');
xlabel('Tiempo/s');
ylabel('Amplitud/V');
title('Senal s(t) Demodulada');
ylim([-0.3,1.3]);


%--------------------------------------------
% FIN TIEMPO DE EJECUCION:
% Aqui se contabiliza cuanto duro la modulacion
%--------------------------------------------
tdemodtotal = toc;     %Se detiene el temporizador
fprintf('La demodulacion duro %.4f segundos.\n', tdemodtotal);

