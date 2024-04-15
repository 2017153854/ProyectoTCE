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



%--------------------------------------------
% INICIO TIEMPO DE EJECUCION:
% El siguiente fragmento inicia el cronometro para medir el tiempo que dura la moduacion
%--------------------------------------------
tic;     %Se inicia el temporizador
%--------------------------------------------



%--------------------------------------------
% DATO O SYMBOLO DE PRUEBA:
% Se tomara una cadena aleatoria de bits para comparar
% la senal modulada obtenida y la esperada para verificar si hay
% incongruencias.
%--------------------------------------------
data = [1 1 1 0 1 0 1 0 1 0 0 0 1 1 1];
%--------------------------------------------


%--------------------------------------------
% FORMA DE ONDA TEMPORAL:
% Lo primera es mapear la cadena de bits a una senal en el dominio del
% tiempo
%--------------------------------------------
% Vector De Tiempo
f_s = 100;     %Frecuencia de sampleo
t_b = 0.5;     %Tiempo de bit
t = 0 : 1/f_s : (length(data)*t_b - 1/f_s);     %Tiempo 

% Senal Mensaje m(t) De Tipo NRZ Unipolar
m_t = [];      %Senal de mensaje m(t)
i = 1; % Auxiliar
while true
    if i > length(data)    %Condicion de parada
        break;
    end
    if data(i) == 1     %Tren de pulso para los 1's
        m_t = [m_t ones(1, t_b*f_s)];
    else     %Tren de zeros para los 0's
        m_t = [m_t zeros(1, t_b*f_s)];
    end
    i = i + 1;
end
%--------------------------------------------



%--------------------------------------------
% MODULACION GFSK:
% Para esto es necesario hacer pasar la senal m(t) por el filtro gausseano
% y posteriormente realizar una modulacion FSK corriente
%--------------------------------------------
%Filtro Gausseano
sigma = 100;     %Desviacion Estandar del filtro
gaussian_filter = gausswin(length(m_t), sigma);     %Ventana gaussiana

%Aplicacion Del Filtro Gaussiano Al Mensaje m(t)
m_t_filtered = conv(m_t, gaussian_filter, 'same');

%Modulacion FSK
u = max(m_t_filtered)/2;     %Umbral para saber cual frecuencia usar
a = 0.35;     %Indice de modulacion
f_c0 = 3;     %Frecuencia para 0's
f_c1 = 12;     %Frecuencia para 1's
s_t = []*7500;     %Senal modulada s(t)
for i=1 : length(m_t_filtered)
    if m_t_filtered(i) < u
        s_t(i) = cos(2*pi*f_c0*t(i) + a*m_t_filtered(i));     %FSK para 0's
    else
        s_t(i) = cos(2*pi*f_c1*t(i) + a*m_t_filtered(i));     %FSK para 1's
    end
end
%--------------------------------------------



%--------------------------------------------
% FIN TIEMPO DE EJECUCION:
% Aqui se contabiliza canto duro la modulacion
%--------------------------------------------
t_mod = toc;     %Se detiene el temporizador
fprintf('La modulacion duro %.4f segundos.\n', t_mod);
%--------------------------------------------



%--------------------------------------------
% VISUALIZACION DE RESULTADOS:
% A continuacion se plotean las senales m_t (mensaje), 
% m_t_filtered (senal a la salida del filtro gaussiano), s_t (senal modulada)
%--------------------------------------------
figure;      %Ventana

subplot(3, 1, 1);     % Grafica de m_t
plot(t, m_t);
title('Mensaje m(t): 1 1 1 0 1 0 1 0 1 0 0 0 1 1 1');
xlabel('Tiempo (s)');
ylabel('Amplitud');

subplot(3, 1, 2);     % Grafica de m_t_filtered
plot(t, m_t_filtered);
title('Mensaje m(t) A La Salida Del Filtro Gaussiano');
xlabel('Tiempo (s)');
ylabel('Amplitud');

subplot(3, 1, 3);     % Grafica de gaussian_filter
plot(t, s_t);
title('Senal Modulada s(t)');
xlabel('Tiempo (s)');
ylabel('Amplitud');
%--------------------------------------------

