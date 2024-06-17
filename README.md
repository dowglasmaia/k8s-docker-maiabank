# **API Maiabank**

### Configuração para Implantar um Deployment e um Service no Kubernetes

---

## Estrutura do Arquivo `deployment.yaml`

### **1. Deployment**

O **Deployment** gerencia a implantação e a atualização de contêineres, garantindo que um número especificado de réplicas esteja sempre em execução.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: maiabank
spec:
  replicas: 5
  selector:
    matchLabels:
      app: maiabank
  template:
    metadata:
      labels:
        app: maiabank
    spec:
      containers:
        - name: maiabankpix
          image: dowglasmaia/maiabank:latest
          ports:
            - name: http
              containerPort: 8089
              protocol: TCP
```

#### **Componentes do Deployment:**

- **`apiVersion: apps/v1`**: Define a versão da API usada para o Deployment.
- **`kind: Deployment`**: Especifica que o tipo de recurso é um Deployment.
- **`metadata`**: Metadados sobre o recurso, como o nome (`maiabank`).
- **`spec`**: Especificações do Deployment:
    - **`replicas: 5`**: Define o número de réplicas (5 Pods).
    - **`selector`**: Seleciona Pods com a label `app: maiabank`.
    - **`template`**: Modelo para os Pods:
        - **`metadata`**: Labels para os Pods (`app: maiabank`).
        - **`spec`**: Especificações dos containers:
            - **`containers`**: Lista de containers:
                - **`name: maiabankpix`**: Nome do container.
                - **`image: dowglasmaia/maiabank:latest`**: Imagem do container.
                - **`ports`**: Portas expostas:
                    - **`containerPort: 8089`**: Porta exposta no container.

### **2. Service**

O **Service** expõe o Deployment ao tráfego de rede e distribui solicitações entre os Pods.

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: maiabank
spec:
  selector:
    app: maiabank
  type: NodePort
  ports:
    - name: http
      port: 80
      targetPort: 8089
      protocol: TCP
      nodePort: 30000
```

#### **Componentes do Service:**

- **`apiVersion: v1`**: Define a versão da API usada para o Service.
- **`kind: Service`**: Especifica que o tipo de recurso é um Service.
- **`metadata`**: Metadados sobre o recurso, como o nome (`maiabank`).
- **`spec`**: Especificações do Service:
    - **`selector`**: Seleciona Pods com a label `app: maiabank`.
    - **`type: NodePort`**: Tipo de Service que expõe o serviço em uma porta específica de cada nó.
    - **`ports`**: Portas usadas pelo Service:
        - **`port: 80`**: Porta exposta no Service.
        - **`targetPort: 8089`**: Porta no container onde o tráfego é direcionado.
        - **`nodePort: 30000`**: Porta externa para acessar o serviço.

### **Fluxo Geral**

1. **Deployment**:
    - O Deployment `maiabank` cria 5 réplicas de Pods usando a imagem `dowglasmaia/maiabank:latest`, que escutam na porta `8089`.

2. **Service**:
    - O Service `maiabank` expõe os Pods na porta `30000` externamente, redirecionando para a porta `8089` dos containers.

### **Fluxo de Solicitações**

1. **Usuário Externo**: Acessa o serviço na porta `30000` do IP do nó do cluster.
2. **Service**: Encaminha o tráfego para a porta `8089` dos containers nos Pods do Deployment.
3. **Pod/Container**: O container `maiabankpix` processa e responde à solicitação.

---

## Passos para Criar o Cluster K3d e Fazer o Deploy da Aplicação Kubernetes

### **1. Instalação e Preparação**

1. **Instalar K3d**:
    - K3d facilita a criação de clusters Kubernetes com k3s dentro de contêineres Docker.
    - Certifique-se de que o Docker está instalado e rodando.

   Instale o K3d:
   ```bash
   curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
   ```

2. **Instalar `kubectl`**:
    - `kubectl` é a ferramenta de linha de comando para gerenciar clusters Kubernetes.

   Instale o `kubectl`:
   ```bash
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   chmod +x kubectl
   sudo mv kubectl /usr/local/bin/
   ```

### **2. Criar o Cluster K3d**

Crie um cluster K3d com 4 servidores e 4 agentes, mapeando a porta `30000`:

```bash
k3d cluster create maiacluster --servers 4 --agents 4 -p "30000:30000@loadbalancer"
```

#### **Componentes do Comando**:

- **`--servers 4`**: Define 4 nós de servidor.
- **`--agents 4`**: Define 4 nós de agente.
- **`-p "30000:30000@loadbalancer"`**: Mapeia a porta `30000` no host para o load balancer.

### **3. Verificar o Cluster**

Verifique se o cluster foi criado e os nós estão rodando:

```bash
k3d cluster list
kubectl get nodes
```

### **4. Deploy da Aplicação com Kubernetes**

Navegue até o diretório da aplicação e aplique o manifesto `deployment.yaml`:

```bash
cd /d/projetos/Desafios_2024/maiabank
kubectl apply -f k8s/deployment.yaml
```

#### **Explicação do Manifesto**:

- **Deployment**: Cria e gerencia réplicas do aplicativo.
- **Service**: Exponibiliza o aplicativo externamente.

### **5. Verificar o Deploy**

Verifique a criação dos recursos:

1. **Listar Pods**:
   ```bash
   kubectl get pods
   ```

2. **Verificar Serviços**:
   ```bash
   kubectl get services
   ```

3. **Obter Informações do Cluster**:
   ```bash
   kubectl cluster-info
   ```

4. **Acessar o Serviço Externo**:
   Acesse o serviço externamente na porta `30000`:
   ```bash
   http://<IP-do-Host>:30000
   ```

---

## **Resumo dos Passos**

1. **Instalar Ferramentas**:
    - K3d e `kubectl`.

2. **Criar Cluster K3d**:
    - Executar `k3d cluster create maiacluster --servers 4 --agents 4 -p "30000:30000@loadbalancer"`.

3. **Verificar Cluster**:
    - Listar clusters e nós.

4. **Deploy da Aplicação**:
    - Aplicar o manifesto `deployment.yaml`.

5. **Verificar e Acessar Aplicação**:
    - Verificar Pods e Serviços.
    - Acessar externamente via `http://<IP-do-Host>:30000`.

---

**Exemplos de Comandos Utilizados**:

- **Criar Cluster**:
  ```bash
  k3d cluster create maiacluster --servers 4 --agents 4 -p "30000:30000@loadbalancer"
  ```

- **Aplicar Manifesto Kubernetes**:
  ```bash
  kubectl apply -f k8s/deployment.yaml
  ```

- **Verificar Pods**:
  ```bash
  kubectl get pods
  ```

- **Verificar Serviços**:
  ```bash
  kubectl get services
  ```

---
Seguindo esses passos, você cria um cluster Kubernetes com K3d e implanta a aplicação Maiabank, tornando-a acessível externamente.

---

## Explicada do Dockerfile:

```dockerfile
# Fase 1: Build
FROM maven:3.8.4-openjdk-17-slim AS build

# Define o diretório de trabalho inicial
WORKDIR /maiabank

# Copia o arquivo pom.xml e resolve as dependências
COPY pom.xml /maiabank/
RUN mvn dependency:resolve

# Copia o código fonte e compila o projeto
COPY src /maiabank/src
RUN mvn clean install

# Fase 2: Runtime
FROM amazoncorretto:17-alpine3.16

# Informações de manutenção
LABEL MAINTAINER="Dowglas Maia"

# Variáveis de ambiente para configuração
ENV SPRING_LOGGING_LEVEL=INFO
ENV ACTUATOR_PORT=8089
ENV PORT=8089

# Ajusta o fuso horário para São Paulo
RUN rm -f /etc/localtime && ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

# Copia o arquivo JAR gerado na fase de build
COPY --from=build /maiabank/target/*.jar /usr/src/app/maiabank-api.jar

# Define o diretório de trabalho para a execução do aplicativo
WORKDIR /usr/src/app

# Comando para iniciar a aplicação
ENTRYPOINT ["java", "-noverify", "-Dfile.encoding=UTF-8", "-Dlogging.level.root=${SPRING_LOGGING_LEVEL}", "-Dmanagement.server.port=${ACTUATOR_PORT}", "-jar", "/usr/src/app/maiabank-api.jar", "--server.port=${PORT}"]

# Exposição das portas
EXPOSE ${PORT} ${ACTUATOR_PORT}
```

### Passo a Passo do Dockerfile

#### Fase 1: Build

1. **Imagem Base:** Usa a imagem `maven:3.8.4-openjdk-17-slim` para compilar a aplicação.
2. **Diretório de Trabalho:** Define `/maiabank` como o diretório de trabalho.
3. **Copia e Resolve Dependências:** Copia `pom.xml` e resolve dependências do Maven.
4. **Copia o Código Fonte:** Copia o diretório `src` contendo o código fonte.
5. **Compila e Gera o Artefato:** Executa `mvn clean install` para compilar e gerar o JAR.

#### Fase 2: Runtime

1. **Imagem Base:** Usa `amazoncorretto:17-alpine3.16` para a execução da aplicação.
2. **Informações de Manutenção:** Define o rótulo do mantenedor.
3. **Configurações de Ambiente:** Define variáveis de ambiente para configuração da aplicação.
4. **Ajusta Fuso Horário:** Configura o fuso horário para São Paulo.
5. **Copia o JAR:** Copia o JAR gerado na fase de build para o diretório `/usr/src/app`.
6. **Diretório de Trabalho:** Define `/usr/src/app` como diretório de trabalho.
7. **Ponto de Entrada:** Define o comando `ENTRYPOINT` para executar a aplicação.
8. **Exposição das Portas:** Expõe as portas configuradas.

### Resumo

Este Dockerfile compila a aplicação Java na fase de build e depois a executa em uma imagem leve de runtime baseada em Amazon Corretto. Ele utiliza variáveis de ambiente para configurar a aplicação e ajusta o fuso horário. As boas práticas aplicadas garantem uma imagem eficiente e flexível.

--- 

## Vamos detalhar e explicar o `docker-compose.yml`:

```yaml
version: "3.3"
services:
  maiabank-api:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8089:8089"
    networks:
      - maianet

networks:
  maianet:
    driver: bridge
```

### Estrutura e Explicação

#### 1. `version: "3.3"`

- **Descrição:** Define a versão do formato de arquivo `docker-compose.yml` que está sendo usado.
- **Significado:** O Compose usa diferentes versões de arquivo para aproveitar novos recursos. A versão 3.3 é compatível com recursos do Docker 1.13.0+ e Docker Compose 1.13.0+.

#### 2. `services`

- **Descrição:** Define uma lista de serviços que serão gerenciados pelo Compose.
- **Significado:** Cada entrada em `services` representa um contêiner ou um conjunto de contêineres que compõem sua aplicação.

##### `maiabank-api`

- **Descrição:** Define o serviço `maiabank-api`.
- **Significado:** Este é o nome do serviço que será criado e gerenciado pelo Docker Compose. Vamos explorar suas configurações:

###### `build`

- **Descrição:** Especifica como construir a imagem Docker para o serviço.
- **Significado:** Define a origem e o contexto para a construção da imagem Docker.

    - **`context: .`**
        - **Descrição:** Define o contexto de build para o Docker, que é o diretório atual (`.`).
        - **Significado:** O Docker usará o diretório atual como o contexto para construir a imagem, incluindo arquivos e diretórios a partir desse ponto.

    - **`dockerfile: Dockerfile`**
        - **Descrição:** Especifica o Dockerfile a ser usado para construir a imagem.
        - **Significado:** Indica ao Docker Compose que o Dockerfile localizado no contexto (diretório atual) será usado para construir a imagem para este serviço.

###### `ports`

- **Descrição:** Mapeia as portas do contêiner para a máquina host.
- **Significado:** Define quais portas serão expostas e como elas serão acessíveis.

    - **`"8089:8089"`**
        - **Descrição:** Mapeia a porta `8089` do host para a porta `8089` do contêiner.
        - **Significado:** A aplicação rodando no contêiner escutará na porta `8089`, e essa porta será acessível externamente na porta `8089` da máquina host. Assim, acessar `localhost:8089` no host redireciona para a aplicação dentro do contêiner.

###### `networks`

- **Descrição:** Define as redes em que o serviço estará conectado.
- **Significado:** Especifica a rede chamada `maianet` para o serviço `maiabank-api`.

#### 3. `networks`

- **Descrição:** Define as redes usadas pelos serviços.
- **Significado:** Permite a comunicação entre contêineres através de redes definidas.

##### `maianet`

- **Descrição:** Nome da rede personalizada.
- **Significado:** Uma rede chamada `maianet` será criada para uso pelos serviços.

###### `driver: bridge`

- **Descrição:** Especifica o driver de rede a ser usado.
- **Significado:** Utiliza o driver `bridge`, que é o padrão para redes Docker, e cria uma rede de ponte permitindo a comunicação entre os contêineres conectados a ela. O `bridge` é o driver de rede padrão que isola contêineres em uma rede interna, com a capacidade de comunicar-se entre si.

### Funcionamento Geral

1. **Build e Deploy:**
    - O Compose construirá a imagem Docker para `maiabank-api` usando o `Dockerfile` no contexto atual.
    - Em seguida, ele cria e inicia um contêiner a partir dessa imagem.

2. **Exposição de Portas:**
    - A porta `8089` no contêiner `maiabank-api` é mapeada para a porta `8089` no host, permitindo o acesso à aplicação do contêiner através de `localhost:8089`.

3. **Rede Personalizada:**
    - O serviço `maiabank-api` será conectado à rede `maianet`, permitindo que ele se comunique com outros serviços que também estejam conectados a essa rede (embora no exemplo atual, não haja outros serviços especificados).

### Resumo

- O `docker-compose.yml` configura a construção e execução do serviço `maiabank-api`.
- Ele usa um Dockerfile para construir a imagem e mapeia a porta `8089` do contêiner para o host.
- Os contêineres se conectam através da rede personalizada `maianet`, permitindo comunicação isolada entre serviços na mesma rede.

Esse setup é útil para desenvolvimento e testes, permitindo a construção de contêineres e configuração de redes de forma fácil e consistente com um único comando (`docker-compose up --build`).

