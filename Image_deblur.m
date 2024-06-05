% MATLAB Code for Image Deblurring using GMRES with proper restarts
close all; 
clear all; 
clc;

format compact; format shortG;
DispFlag = true;
% Read and process the image
orig_im = imread(['tulip.jpeg']); % Load an example image file
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
maxItr = 100;   % Maximum iterations allowed before restart

method = 'Tikhonov for Truncation';
% Set of error tolerances for GMRES
er_tol = [0.1, 0.05, 0.001, 5e-05, 1e-07];
times = zeros(size(er_tol));
iterations = zeros(size(er_tol));
relative_residuals = zeros(size(er_tol));
norm_diff_FH = zeros(size(er_tol));
norm_diff_FG = zeros(size(er_tol));

switch method
    case 'GMRES'

% Deblurring process
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

% Display the results in a table format
        disp('Etol      Time(s)    Iterations    RelRes      ||F-H||2    ||F-G||2');
        for i = 1:length(er_tol)
            fprintf('%6.1e  %8.5f    %6d      %8.1e    %8.3f    %8.3f\n', ...
                er_tol(i), times(i), iterations(i), relative_residuals(i), norm_diff_FH(i), norm_diff_FG(i));
        end


    case 'Tikhonov'

% Creates vector of alpha values and stores length
        alptest = [0.1 0.05 0.001 0.00005 0.0000001];
        nalp = length(alptest);
        figure
        for i = 1:nalp
            if (Itr < maxItr)
                tic
                % SVD of blur matrices A and B
                [Ua, Sa, Va] = svd(full(A));
                [Ub, Sb, Vb] = svd(full(B));
                % Change of basis for G for LS solve
                Ghat = Ub'*G*Ua;
                % Convenient matrix for LS solve
                S = diag(Sb)*(diag(Sa))';
                % Deblurs, plots image for each alpha, stores solution time
                alp = alptest(i);
                Fhat = (S.*Ghat) ./ (S.*S+alp^2);
                F = Vb*Fhat*Va';
                TikReg_db_time(i) = toc;
                
                if(DispFlag)
                    subplot(2,3,i)
                    imshow(F)
                    title(sprintf('a = %4.2e',alp))
                end
                % Stores 2-norm error of deblurred im. F and orig. im H
                TikReg_orig_err(i) = norm(abs(F-H),2);
                % Stores 2-norm error of deblurred im. F and blurred im G
                TikReg_blur_err(i) = norm(abs(F-G),2);
                Itr=Itr+1;
            end
        end

           TikReg_db_time
           TikReg_orig_err
           TikReg_blur_err

    case 'Tikhonov for Truncation'
        alptest = [0.1 0.05 0.001 0.00005 0.0000001];
        nalp = length(alptest);
        figure
        for i = 1:nalp
            if (Itr < maxItr)
                tic
                % SVD of blur matrices A and B
                [Ua, Sa, Va] = svd(full(A));
                [Ub, Sb, Vb] = svd(full(B));
                % Change of basis for G for LS solve
                Ghat = Ub'*G*Ua;
                % Convenient matrix for LS solve
                S = diag(Sb)*(diag(Sa))';
                % Deblurs, plots image for each alpha, stores solution time
                Fhat = Ghat./S;
                alp = alptest(i);
                ind = S > alp;
                Fnew = Fhat .* ind;
                F = Vb*Fnew*Va';
                TSVD_db_time(i) = toc;
            end
            if(DispFlag)
                subplot(3,2,i)
                imshow(F)
                title(sprintf('a = %4.2e, p = %d',alp,sum(sum(ind))))
            end
            
            % Stores 2-norm error of deblurred im. F and orig. im H
            TSVD_orig_err(i) = norm(abs(F-H),2);
            % Stores 2-norm error of deblurred im. F and blurred im G
            TSVD_blur_err(i) = norm(abs(F-G),2);
            Itr=Itr+1;
        end
        TSVD_db_time
        TSVD_orig_err
        TSVD_blur_err
end