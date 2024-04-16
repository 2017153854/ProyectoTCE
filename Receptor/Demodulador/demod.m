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



%--------------------------------------------
% DATO DE PRUEBA (MODULACION DE PRUEBA):
% Lo primero es realizar la modulacion de una secuencia
% aleatoria de bits para obtener la senal de entrada del demodulador.
%--------------------------------------------
data = [1 1 1 0 1 0 1 1 1 0 1 0 1 1 1];

% Vector De Tiempo Del Modulador
f_s = 1000;     %Frecuencia de sampleo
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

%Filtro Gausseano
sigma = 100;     %Desviacion Estandar del filtro
gaussian_filter = gausswin(length(m_t), sigma);     %Ventana gaussiana

%Aplicacion Del Filtro Gaussiano Al Mensaje m(t)
m_t_filtered = conv(m_t, gaussian_filter, 'same');

%Modulacion FSK
u = max(m_t_filtered)/2;     %Umbral para saber cual frecuencia usar
a = 0.35;     %Indice de modulacion
f_c0 = 25;     %Frecuencia para 0's
f_c1 = 50;     %Frecuencia para 1's
s_t = []*7500;     %Senal modulada s(t) en GFSK
for i=1 : length(m_t_filtered)
    if m_t_filtered(i) < u
        s_t(i) = cos(2*pi*f_c0*t(i) + a*m_t_filtered(i));     %FSK para 0's
    else
        s_t(i) = cos(2*pi*f_c1*t(i) + a*m_t_filtered(i));     %FSK para 1's
    end
end
%--------------------------------------------



%--------------------------------------------
% DEMODULADOR:
% Para la implementacion se determinara el periodo promedio de la forma de
% onda de cada bit. Esto es lo mismo que trabajar con frecuencias,
% simplemente habría quue hacerse f=1/T, pero se trabajara con el periodo
% por mayor facilidad.
%--------------------------------------------
u_demod = 0.0137895;     %Umbral para la demodulacion
data_demod = zeros(1, length(data));     %Cadena de bits demodulada

for i=1 : length(data_demod)     % Separar En Bits La Senal s(t) Recibida
    t_valle = [];     %Aquí se almacenan los valor de tiempo en los que se da un valle
    T = 0;     %Suma de todos los periodos de cada bit
    T_prom = 0;     %Periodo promedio de cada bit

    % Indices para recorrer todos los bits por separado
    start_i = (i - 1) * f_s * t_b + 1;
    end_i = i * f_s * t_b;

    t_segment = t(start_i:end_i);     %Tiempo en que se da el bit especifico
    s_t_segment = s_t(start_i:end_i);     %Bit especifico

    % Captura Del Tiempo En Que Se Da Cada Valle
    epsilon = 0.1;     %Se da un 10% de margen, por si el valor exacto de cero no se da
    for j=1 : length(s_t_segment)
        if abs(s_t_segment(j)) < epsilon
            t_valle = [t_valle, t_segment(j)];
        end
    end

    % Periodo Promedio Del Bit Especifico Que Se Trabaja
    for k=2 : length(t_valle)     %Se recorre t_valle para determinar todos los periodos k-esimos           
        T = T + (t_valle(k) - t_valle(k - 1));     %Todos se suman a T
    end
    T_prom = T / length(t_valle);     %Luego se dividen entre la cantidad que son para sacar el promedio

    % Se Determina Si Se Trata De Un 1 o un 0
    if T_prom < u_demod
        data_demod(i) = 1;
    else
        data_demod(i) = 0;
    end
end

% Vector De Tiempo Para El Demodulador
t_demod = linspace(0, length(data_demod)*t_b, length(data_demod));
%--------------------------------------------



%--------------------------------------------
% VISUALIZACION DE RESULTADOS:
% A continuacion se plotean las senales m_t (mensaje), 
% m_t_filtered (senal a la salida del filtro gaussiano), s_t (senal modulada)
% y data_demod (mensaje demodulado)
%--------------------------------------------
figure;      %Ventana

subplot(4, 1, 1);     % Grafica de m_t
plot(t, m_t);
title('Mensaje m(t): 1 1 1 0 1 0 1 1 1 0 1 0 1 1 1');
xlabel('Tiempo (s)');
ylabel('Amplitud');
ylim([-0.5 1.5]);

subplot(4, 1, 2);     % Grafica de m_t_filtered
plot(t, m_t_filtered);
title('Mensaje m(t) A La Salida Del Filtro Gaussiano');
xlabel('Tiempo (s)');
ylabel('Amplitud');
ylim([min(m_t_filtered)-10 max(m_t_filtered)+10]);

subplot(4, 1, 3);     % Grafica de s_t
plot(t, s_t);
title('Senal Modulada s(t)');
xlabel('Tiempo (s)');
ylabel('Amplitud');
ylim([-1.3 1.3]);

subplot(4,1,4);     %Grafica de data_demod
stairs(t_demod, data_demod);
title('Senal Demodulada');
xlabel('Tiempo (s)');
ylabel('Amplitud');
ylim([-0.5 1.5]);

disp('Senal m(t) demodulada:');     %Impresion de la senal "mensaje m(t)" demodulada
disp(data_demod);
%--------------------------------------------

