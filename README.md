# projetoPG2
Segundo Projeto para disciplina de Processamento Gráfico (2016.2) do Centro de Informática da UFPE

## Descrição:
TEMA 2: Rugosidade através de perturbações de normais (3 alunos).
Objetivo:

**Parte Geral:** Implementar o método de visualização de objetos triangulados, através do algoritmo de conversão por varredura, com métodos de interpolação de Phong, com a visibilidade garantida pelo algoritmo do “z-buffer”.

**Parte Específica:** Produzir rugosidade através de perturbações nas normais. Descrição O usuário, através de arquivos-texto ou interface gráfica, entra com os dados do objeto (triangulado, com lista dos vértices e da conectividade, que determina os triângulos, de um arquivo-texto), os atributos do objeto (ka, kd e ks, pontos flutuantes entre 0 e 1, η, ponto flutuante positivo e Od, tripla de pontos flutuantes entre 0 e 1), atributos da cena (Ia, IL, triplas de ponto flutuante entre 0 e 255, PL, tripla de ponto flutuante) e os atributos da câmera virtual (C, N e V, triplas de pontos flutuantes, d, hx, e hy, pontos flutuantes positivos). O seu sistema começa preparando a câmera, ortogonalizando V e gerando U, e depois os normalizando, fazer a mudança de coordenadas para o sistema de vista de todos os vértices dos objetos e da posição da fonte de luz PL, gerar as normais dos triângulos e gerar as normais dos vértices (como recomendado em sala de aula). Para cada triângulo de cada objeto, calculam-se as projeções dos seus vértices e inicia-se a sua conversão por varredura. Para cada pixel (x, yscan), calculam-se suas coordenadas baricêntricas com relação aos vértices projetados, e multiplicam-se essas coordenadas pelos correspondentes vértices do triângulo 3D original para se obter uma aproximação para o ponto 3D original correspondente ao pixel atual. Após uma consulta ao z-buffer, se for o caso, calcula-se uma aproximação para a normal do ponto utilizando-se mesmas coordenadas baricêntricas multiplicadas pelas normais dos respectivos vértices originais. Geram-se números aleatórios para se multiplicar pelos vetores das arestas do triângulo para serem somados à normal (a perturbação é paralela ao plano do triângulo, por isso se utilizam os vetores das arestas). Deixar um fator multiplicador arbitrado pelo usuário para controlar o grau de rugosidade.  Calculam-se também os demais vetores (L, V e R) e os substitui na equação do modelo de iluminação de Phong produzindo a cor do pixel atual. 

###### Autores:
  - Bruno Henrique Lima Vieira de Melo ([@bhlvm](https://github.com/bhlvm))
  - Fanny Chien ([@fc2](https://github.com/fc2))
  - Hilton Pintor Bezerra Leite ([@hpbl](https://github.com/hpbl))
  
  
\#fighting :muscle:
