function t01() 
    % Esta funcion es la encargada de llamar a las otras funciones. 
    % Defininendo aca alguno de los inputs de las mismas (los que no se
    % variaran) permite un control mas rapido del codigo.
    i     =  100;
    t     =  150;
    Cmax  =  10;
    Cmin  = -10;
    Ct    =  5;
    k     =  2;
    P0    =  0.5;
    delta =  0.01;
    
    
    close all
    %parametros a variar: delta y P0
    diagrama_fases(i,t,Cmax,Cmin,Ct,k)
    
    %parametros a variar: P0
    grafico_bifurcacion(i,t,Cmax,Cmin,Ct,k,delta)
        
end

function diagrama_fases(i,t,Cmax,Cmin,Ct,k)
    %Varia los parametros delta y P0 y grafica el diagrama de fases fundamental
    %matriz Retrun Value(RV) tiene el tipo de convergencia para cada par (P0,delta)
    
    n = 10; 
    RV = NaN(n,n);
    desde = 0.01;
    hasta =0.99;
    paso = (desde+hasta)/n;
    for i=1:1:n
      for j=1:1:n 
        P0    =  paso*i;
        delta =  paso*j;
        [C,O,S,P,T,tipo_de_convergencia] = funcion_principal(i,t,Cmax,Cmin,Ct,k,delta,P0);
        RV(i,j) = tipo_de_convergencia;
      end
    end
    
    %grafico
    
    x = [desde hasta];
    y = [desde hasta];
    figure()

    imagesc(x,y,RV,[0,4])
    title('Diagrama de fase fundamental')
    xlabel('Delta');
    ylabel('P0');

end

function grafico_bifurcacion(i,t,Cmax,Cmin,Ct,k,delta)
    %Realiza una analisis de bifurcacion en la region Tbp.
    
    
    n = 10; 
    desde = 0.01;
    hasta =0.99;
    paso = (desde+hasta)/n;
    vec_P0 = NaN(n,1);
    cantidades = NaN(n,2); %cantidades(1)=T+ y canditades(2) = T- para cada iteracion
    for i=1:1:n  
        P0    =  paso*i;
        vec_P0(i,1) = P0;
        [C,O,S,P,T,tipo_de_convergencia] = funcion_principal(i,t,Cmax,Cmin,Ct,k,delta,P0);
        cantidades(i,:) = [T(1),T(2)];    
    end
    
    %grafico
    figure()
    plot(vec_P0,cantidades(:,1),'o')
    hold on
    plot(vec_P0,cantidades(:,2),'rx')
    title('Analisis de la bifurcacion')
    xlabel('P0');
    ylabel('Estado final');
  
end

function [C,O,S,P,T,tipo_de_convergencia] = funcion_principal(i,t,Cmax,Cmin,Ct,k,delta,P0)
  %ejemplo de comando:
  %   [C,O,S,P,T,tipo_de_convergencia] = t01(10,15,   10,  -10,  5, 2,     1, 3);
  %   [C,O,S,P,T,tipo_de_convergencia] = t01( i, t, Cmax, Cmin, Ct, k, delta,P0);


  %Donde i es numero de personas,t es la cantidad de iteraciones,
  %   Cmax y Cmin determinan el rango de persuasion, Ct es el threshold,
  %   k y delta son parametros de la interaccion.

  %Los outputs son matrices C y O que tienen i columnas y t filas.
  %   representan la persuasion y la opinion para cada persona i 
  %   en el instante t.

  %Creo una matriz con como van evolucionando los vectores:
  %   esto podria hacerse muy pesado, pero me permite saber
  %   como era cada vector para cada t. La otra opcion es 
  %   graficar iteracion a iteracion sobre un mismo grafico.
  %   Sino tambien se pueden tirar los datos del medio y quedarse
  %   con el estado inicial y final solamente.



  %matriz persuasion C
  [C] = crear_matriz_C(i,t,Cmax,Cmin,Ct,P0);
  
  %matriz opinion O
  O = zeros(t,i);
  O(1,:) = (C(1,:) > Ct) - (C(1,:) < -Ct);
  
  %comienza la iteracion
  iteracion = 1;
  [tipo_de_convergencia, no_convergio ] = convergencia(O(1,:));
  while iteracion < t && no_convergio  %Para cuando converge o supera el tope de tiempo t
      [persona1, persona2] = selector_personas(i);

      C(iteracion+1,:) = C(iteracion,:);
      O(iteracion+1,:) = O(iteracion,:);
      
      %hago interactuar a persona1 con persona2
      [C(iteracion+1,persona1),C(iteracion+1,persona2), ...
        O(iteracion+1,persona1), O(iteracion+1,persona2)] = ...
         interactuan(C(iteracion,persona1),C(iteracion,persona2), ...
          O(iteracion,persona1), O(iteracion,persona2),k,delta,Ct);
          
      [tipo_de_convergencia, no_convergio ] = convergencia(O(iteracion,:));
      iteracion = iteracion + 1;
  end
  
  [S,P,T] = resultados(O);
  
  
end

function [C] = crear_matriz_C(i,t,Cmax,Cmin,Ct,P0)
  %matriz persuasion C
  %en donde en cada fila de la matriz esta el vector persuasion a tiempo t
  % a continuacion se presentan varias formas de definir C. Descomentar la
  % opcion elegida.
  C = zeros(t,i);
  %      Forma random:
  %C(1,:) = round( rand(1,i) * (Cmax - Cmin) + Cmin );
  
  %      Forma controlada:
  %C(1,:) = ones(1,i)*2;
  %C(1,1) = -4;
  %C(1,2) = 10;

  %      Forma prefijada con P0 (P0 debe ser menor que el total de personas i)
  cantidad_P0 = round(i*P0);
  cantidad_P1 = floor((i-cantidad_P0)/2); %la canditad de P-1 es igual a la de P1
  vector_aux = zeros(1,i);
  vector_aux(1,1:cantidad_P1) = round( rand(1,cantidad_P1) * (Cmax - Ct) + Ct );
  vector_aux(1,cantidad_P1+1:2*cantidad_P1) = round( rand(1,cantidad_P1) * (Cmin + Ct) - Ct );
  vector_aux(1,cantidad_P1*2+1:i) = round( rand(1, i - cantidad_P1*2 ) * 2*Ct - Ct );
 
  C(1,:) = vector_aux(randperm(i));
end


function [p1,p2] = selector_personas(i)
  %funcion selecciona las posisiones correspondientes a las
  %   dos personas van a interactuar.
  
  p1 = ceil(rand()*i);
  p2 = ceil(rand()*i);
  %p1=1;
  %p2=2;
  
end


function [C_tf_p1,C_tf_p2,O_tf_p1,O_tf_p2] ...
          = interactuan(C_t0_p1,C_t0_p2, O_t0_p1,O_t0_p2, k, delta,Ct)
          
  %Como interactuan dos personas.
  %  inputs:
  %  C_t0_p1 corresponde al C a un tiempo t0 para la persona p1
  %  C_t0_p2 corresponde al C a un tiempo t0 para la persona p2
  %  O_t0_p1 corresponde al O a un tiempo t0 para la persona p1
  %  O_t0_p2 corresponde al O a un tiempo t0 para la persona p2
  %  k, delta y Ct son parametros
  
  %  outputs:
  %  C_tf_p1 corresponde al C a un tiempo tf para la persona p1
  %  C_tf_p2 corresponde al C a un tiempo tf para la persona p2
  %  O_tf_p1 corresponde al O a un tiempo tf para la persona p1
  %  O_tf_p2 corresponde al O a un tiempo tf para la persona p2
  
  C_tf_p1 = C_t0_p1;
  C_tf_p2 = C_t0_p2;

  los_cambie = false;
  
  if (O_t0_p1 == O_t0_p2)
    if  (C_t0_p1 ~= C_t0_p2)
      %opinion igual, persuasion distinta
      
      signo = 2*(C_t0_p1 > C_t0_p2) - 1;
      C_tf_p1 = C_t0_p1 - signo*delta;
      C_tf_p2 = C_t0_p2 + signo*delta;
    end 
                  
  elseif ( O_t0_p1 + O_t0_p2 == 0 ) 
    %uno es 1 y el otro -1
         
    signo = 2*(C_t0_p1 > C_t0_p2) - 1;
    C_tf_p1 = C_t0_p1 + signo*delta;
    C_tf_p2 = C_t0_p2 - signo*delta; 
              
              
  else
            
                  
                  if O_t0_p1 == 0
                      %tomo persona1 = +- 1 y persona2 = 0, 
                      %   si no es asi, los cambio
                      
                      variable_auxiliar = C_t0_p1;
                      C_t0_p1 = C_t0_p2;
                      C_t0_p2 = variable_auxiliar;
                      
                      los_cambie = true;
                  end
                  
                  
                  if (abs( C_t0_p1 - C_t0_p2) < delta)
                        deltaeff = abs( C_t0_p1 - C_t0_p2) / 2;

                        signo = 2* (C_t0_p1 == - 1) -1;
                        C_tf_p1 = C_t0_p1 + signo*deltaeff;
                        C_tf_p2 = C_t0_p2 - signo*k*deltaeff; 
                  
                  else
                        signo = 2* (C_t0_p1 == - 1) -1;
                        C_tf_p1 = C_t0_p1 + signo*delta;
                        C_tf_p2 = C_t0_p2 - signo*k*delta; 
                  
                  end
                        
  end

  if los_cambie
    % si los cambie, tengo que volverlos a dar vuelta
    
    variable_auxiliar = C_tf_p1;
    C_tf_p1 = C_tf_p2;
    C_tf_p2 = variable_auxiliar;
  end
  
  O_tf_p1 = (C_tf_p1 > Ct) - (C_tf_p1 < -Ct);
  O_tf_p2 = (C_tf_p2 > Ct) - (C_tf_p2 < -Ct);

end



function [S,P,T] = resultados(O)
  %calcula S, P y T a partir de la matriz O
  [altura,ancho] = size(O);
  S1  = zeros(altura,1);
  S_1 = zeros(altura,1);
  S0  = zeros(altura,1);
  
  for i=1:1:altura
    S1(i)  = sum(O(i,:)== 1)/i;  %porcentaje de unos  
    S_1(i) = sum(O(i,:)==-1)/i;  %porcentaje de menos unos 
    S0(i)  = sum(O(i,:)== 0)/i;  %porcentaje de ceros 
  end
  
  S = [S1, S_1, S0];
  P = S(1,:);                %P = [P1, P_1, P0];
  T = S(altura,:);           %T = [T1, T_1, T0];
  
end



function [tipo_de_convergencia, no_convergio ] = convergencia(O_tf)
  % no_convergio es un booleano
  %tipo_de_convergencia puede valer:
  %                                 0   si no convergio
  %                                 1   si la convergencia es a T0
  %                                 2   si la convergencia es a T+
  %                                 3   si la convergencia es a T-
  %                                 4   si la convergencia es a Tbp

  no_convergio = true;
  tipo_de_convergencia = 0;


  if (sum(O_tf==0) == length(O_tf) )
    no_convergio = false;
    tipo_de_convergencia = 1;
  elseif (sum(O_tf==1) == length(O_tf))
    no_convergio = false;
    tipo_de_convergencia = 2;
  elseif (sum(O_tf==-1) == length(O_tf))
    no_convergio = false;
    tipo_de_convergencia = 3;
  elseif (sum(O_tf==0) == 0)
    no_convergio = false;
    tipo_de_convergencia = 4;
  end


end





% Dudas:
%  ¿Puede haber valores Ci mayores a Cmax y menores a Cmin?
%  ¿Como se que converge?
%  graficos

