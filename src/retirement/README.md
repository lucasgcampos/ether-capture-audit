Severidade alta:
- Falta de verificação se o withdraw já foi chamado (isComplete()), possibilitando o owner drenar os fundos fazendo múltiplas chamadas
- Beneficiário tem a possibilidade de explorar um underflow devido a versão do solidity drenando os fundos

Severidade média:
- Versão muito desatualizada do solidity, o que permite explorar o underflow
- Uso do “balance” do contrato no lugar de uma variável própria para isso, possível manipulação por envio externo

Severidade baixa: 
- Uso do block.timestamp pode sofrer pequenas manipulações, mas para esse contexto não teria problema

Sugestões:
- Utilizar versão mais atual do solidity
- Criar variável para controle de saldo que não seja manipulado por envio externo
- Modificar a visibilidade das funções de public para external
- Utilizar a função .call {}(“”) para envio de dinheiro no lugar do transferência
- Adicionar modificador de acesso na função withdraw (OpenZeppelin)
