% TTK4135 - Helicopter lab
% Hints/template for problem 2.
% Updated spring 2018, Andreas L. Flåten

%% Initialization and model definition
init; % Change this to the init file corresponding to your helicopter

% Discrete time system model. x = [lambda r p p_dot]'
delta_t	= 0.25; % sampling time

Ac = [0 1 0 0 0 0; 0 0 -K_2 0 0 0; 0 0 0 1 0 0; 0 0 -K_1*K_pp -K_1*K_pd 0 0; 0 0 0 0 0 1; 0 0 0 0 -K_3*K_ep -K_3*K_ed];
Bc = [0 0; 0 0; 0 0; K_1*K_pp 0; 0 0; 0 K_3*K_ep];

A1 = eye(6)+ delta_t * Ac;
B1 = delta_t * Bc;

% Number of states and inputs
nx = size(A1,2); % Number of states (number of columns in A)
mu = size(B1,2); % Number of inputs(number of columns in B)
N  = 40;                               % Time horizon for states
M  = N;                                 % Time horizon for inputs
n = N*nx+N*mu;
z  = zeros(N*nx+M*mu,1);                % Initialize z for the whole horizon
z0 = z;                                 % Initial value for optimization

%% SQP parameters
q1 = 0.1;
q2 = q1;
alpha = 0.2;
beta = 20;
lambda_t = (2*pi)/3;

%% Initial values
x1_0 = pi;                              % Lambda
x2_0 = 0;                               % r
x3_0 = 0;                               % p
x4_0 = 0;                               % p_dot
x5_0 = 0;                               % e
x6_0 = 0;                               % e_dot
x0 = [x1_0 x2_0 x3_0 x4_0 x5_0 x6_0]';  % Initial values
%% Bounds
ul 	    = -1/6*pi;                   % Lower bound on control
uu 	    = 1/6*pi;                   % Upper bound on control

xl      = -Inf*ones(nx,1);              % Lower bound on states (no bound)
xu      = Inf*ones(nx,1);               % Upper bound on states (no bound)
xl(3)   = ul;                           % Lower bound on state x3
xu(3)   = uu;                           % Upper bound on state x3

% Generate constraints on measurements and inputs
[vlb,vub]       = gen_constraints(N,M,xl,xu,ul,uu); % hint: gen_constraints
vlb(N*nx+M*mu)  = 0;                    % We want the last input to be zero
vub(N*nx+M*mu)  = 0;                    % We want the last input to be zero

%% Generate the matrix Q and the vector c (objective function weights in the QP problem) 
Q1 = zeros(nx,nx);
Q1(1,1) = 2;                            % Weight on state x1
Q1(2,2) = 0;                            % Weight on state x2
Q1(3,3) = 0;                            % Weight on state x3
Q1(4,4) = 0;                            % Weight on state x4
Q1(5,5) = 0;
Q1(6,6) = 0;
P = zeros(mu,mu);
P(1,1) = 0.12;                             % Weight on input 1
P(2,2) = 0.12;                             % Weight on input 2

Q = gen_q(Q1,P,N,M);                                  % Generate Q, hint: gen_q
c = zeros(1,5*N);                                  % Generate c, this is the linear constant term in the QP

%% Generate system matrixes for linear model
Aeq = gen_aeq(A1, B1, N, nx, mu);             % Generate A, hint: gen_aeq             
beq = zeros(size(Aeq,1),1);                   % Generate b
beq(1:nx) = A1*x0;

%% Solve QP problem with fmincon

f = @(z) (1/2)*z'*Q*z;
options = optimoptions('fmincon','Algorithm','sqp','MaxFunEvals', 4000);
tic

[z, zval, exitflag] = fmincon(f,z0,[], [], Aeq, beq, vlb, vub, @nl_constraints, options);
toc



%% Extract control inputs and states
u1 = [z(N*nx+1:mu:n); z(n-1)]; % Control input from solution
u2 = [z(N*nx+2:mu:n); z(n)]; 

x1 = [x0(1);z(1:nx:N*nx)];              % State x1 from solution
x2 = [x0(2);z(2:nx:N*nx)];              % State x2 from solution
x3 = [x0(3);z(3:nx:N*nx)];              % State x3 from solution
x4 = [x0(4);z(4:nx:N*nx)];              % State x4 from solution
x5 = [x0(5);z(5:nx:N*nx)];              % State x5 from solution
x6 = [x0(6);z(6:nx:N*nx)];              % State x6 from solution



num_variables = 5/delta_t;
zero_padding = zeros(num_variables,1);
unit_padding  = ones(num_variables,1);

u1   = [zero_padding; u1; zero_padding];
u2   = [zero_padding; u2; zero_padding];
x1  = [pi*unit_padding; x1; zero_padding];
x2  = [zero_padding; x2; zero_padding];
x3  = [zero_padding; x3; zero_padding];
x4  = [zero_padding; x4; zero_padding];
x5  = [zero_padding; x5; zero_padding];
x6  = [zero_padding; x6; zero_padding];

%% Q, R and K matrix
q_1 = 35;  %3
q_2 = 0.5;   % 2
q_3 = 35;   %0.1
q_4 = 1;  % 0.5
q_5 = 0.1;
q_6 = 1;
Q_matrix = diag([q_1,q_2,q_3,q_4,q_5,q_6]);


r_1 = 0.1;
r_2 = 0.1;
R = diag([r_1, r_2]);
K = dlqr(A1,B1,Q_matrix,R);





%% Plotting
t = 0:delta_t:delta_t*(length(u1)-1);
u = [u1, u2];
u_opt = timeseries(u,t);
x = [x1, x2, x3, x4, x5, x6];
x_opt = timeseries(x,t);

figure(2)
subplot(711)
stairs(t,u),grid
ylabel('u')

subplot(712)
plot(t,x1,'m',t,x1,'mo'),grid, hold on;
%plot(t_test,lambda_test), grid
ylabel('lambda')

subplot(713)
plot(t,x2,'m',t,x2','mo'),grid, hold on;
%plot(t_test,r_test), grid
ylabel('r')

subplot(714)
plot(t,x3,'m',t,x3,'mo'),grid, hold on;
%plot(t_test, p_test), grid
ylabel('p')

subplot(715)
plot(t,x4,'m',t,x4','mo'),grid, hold on;
%plot(t_test, pdot_test), grid
xlabel('tid (s)'),ylabel('pdot')

subplot(716)
plot(t,x5,'m',t,x5','mo'),grid, hold on;
%plot(t_test, pdot_test), grid
xlabel('tid (s)'),ylabel('e')

subplot(717)
plot(t,x6,'m',t,x6','mo'),grid, hold on;
%plot(t_test, pdot_test), grid
xlabel('tid (s)'),ylabel('edot')

% Ensure LaTeX interpreter is enabled for y-axis labels
set(gca, 'TickLabelInterpreter', 'latex');

helicopter;
handle=get_param('helicopter','handle');
print(handle,'-dsvg','MyModel');
%winopen MyModel.svg;
