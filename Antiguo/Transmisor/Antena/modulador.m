% Secuencia de bits de entrada
bits = randi([0, 1], 1, 1000); % bits aleatorios

% Parámetros de la modulación GFSK
f_carrier = 2400; % Frecuencia de la portadora en MHz
bt_product = 0.5; % Producto de ancho de banda por tiempo
baud_rate = 1e6; % Tasa de baudios (bps)
bit_duration = 1 / baud_rate; % Duración de un bit en segundos
sampling_freq = 10 * f_carrier; % Frecuencia de muestreo

% Crear señal modulada
modulated_signal = []; % Inicializar la señal modulada

% Modulación GFSK
for i = 1:length(bits)
    t = (i-1)*bit_duration:1/sampling_freq:i*bit_duration; % Tiempo para el bit actual
    if bits(i) == 1
        phase = cumsum(2 * pi * f_carrier * bit_duration * ones(size(t))); % Fase lineal para un bit de valor 1
    else
        phase = cumsum(-2 * pi * f_carrier * bit_duration * ones(size(t))); % Fase lineal para un bit de valor 0
    end
    modulated_signal = [modulated_signal exp(1j * phase)]; % Agregar símbolo modulado
end

% Visualización de la señal modulada
plot(real(modulated_signal), imag(modulated_signal), '.');
xlabel('Parte Real');
ylabel('Parte Imaginaria');
title('Constelación de la señal modulada');

