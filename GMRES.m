clear all; 
clc;

format compact; 
format shortG;
DispFlag = true;

% Read and process the image
orig_im = imread(['tulip.jpeg']); 
if DispFlag
    figure, imshow(orig_im), title('Original Image');
end
X = imrotate(orig_im, -90);
H = rgb2gray(X);
[m, n] = size(H);
scale_factor = 0.25; % Reduce image size by factor of 0.25 for less memory usage
H = imresize(H, scale_factor);
H = im2double(H(:, 1:min(m, n) * scale_factor));
figure, imshow(H, []), title('Original Image');

% Blurring the image
v = [1/4 1/2 1/4];
D = spdiags(repmat(v, min(m, n) * scale_factor, 1), -1:1, min(m, n) * scale_factor, min(m, n) * scale_factor);
A = D^20;
B = D^20;
blur = @(Y) A*Y*A';
vec = @(Y) reshape(Y, [], 1);
unvec = @(y) reshape(y, min(m, n) * scale_factor, min(m, n) * scale_factor);
T = @(z) vec(blur(unvec(z)));
h = vec(H);
g = T(h);
G = unvec(g);
figure, imshow(G, []), title('Blurred Image');
Itr = 0;
restart = 50; % Restart GMRES every 50 iterations
maxItr = 100;   % Maximum iterations before restart


        % Set of error tolerances for GMRES
        er_tol = [0.1, 0.05, 0.001, 5e-05, 1e-07];
        times = zeros(size(er_tol));
        iterations = zeros(size(er_tol));
        relative_residuals = zeros(size(er_tol));
        norm_diff_FH = zeros(size(er_tol));
        norm_diff_FG = zeros(size(er_tol));
        % Deblurring process :GMRES
        figure;
        subplot(2, 3, 1), imshow(H, []), title('Original Image');
        for i = 1:length(er_tol)
            tic;
            [f, flag, relres, Itr] = gmres(T, vec(G), restart, er_tol(i), maxItr);
            times(i) = toc;
            F = unvec(f);
            subplot(2, 3, i+1); % Display deblurred image in a new subplot
            imshow(F, []);
            title(sprintf('Etol = %4.2e', er_tol(i)));
            
            iterations(i) = Itr(2);
            relative_residuals(i) = relres;
            norm_diff_FH(i) = norm(F-H, 'fro');
            norm_diff_FG(i) = norm(F-G, 'fro');
        end

