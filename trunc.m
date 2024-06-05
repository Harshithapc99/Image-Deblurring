close all; 
clear all; 
clc;
format compact; format shortG;

% Read and process the image
orig_im = imread('tulip.jpeg'); % Load an example image file
figure, imshow(orig_im), title('Original Image');
DispFlag = true;
X = imrotate(orig_im, -90);
H = rgb2gray(X);
[m, n] = size(H);
scale_factor = 0.25; % Reduce image size by factor of 0.25 for less memory usage
H = imresize(H, scale_factor);
H = im2double(H(:, 1:min(m, n) * scale_factor));
figure, imshow(H, []), title('Grey Image');

% Blurring the image
v = [1/4 1/2 1/4];
D = spdiags(repmat(v, min(m, n) * scale_factor, 1), -1:1, min(m, n) * scale_factor, min(m, n) * scale_factor);
A = D^20;
B = D^20;
blur = @(Y) A*Y*A';
vec = @(Y) Y(:); % Updated vectorization operation
unvec = @(y) reshape(y, size(H));
T = @(z) vec(blur(unvec(z)));
h = vec(H);
g = T(h);
G = unvec(g);
Itr = 0;
maxItr = 100;
figure, imshow(G, []), title('Blurred Image');

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
alptest
        TSVD_db_time
        TSVD_orig_err
        TSVD_blur_err