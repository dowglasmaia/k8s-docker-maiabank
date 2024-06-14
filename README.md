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

Se precisar de mais detalhes ou ajuda adicional, estou à disposição!

---