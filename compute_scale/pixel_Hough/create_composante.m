function [I_RGB,R,G,B,I_HSV,H,S,V] = create_composante(I_RGB)
    % Composante rouge
    R = I_RGB(:,:,1);
    % Composante verte
    G = I_RGB(:,:,2);
    % Composante bleue
    B = I_RGB(:,:,3);
    %HSV image
    I_HSV=rgb2hsv(I_RGB);
    % Composante H
    H = I_HSV(:,:,1);
    % Composante S
    S = I_HSV(:,:,2);
    % Composante V
    V = I_HSV(:,:,3);
end