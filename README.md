# 💙 Texture Studio Blu
- Esse é um projeto com iniciativa em trazer o Texture Studio para Português e com melhorias com adições de novos componentes que ajudem no desenvolvimentos de novos mapas e modificações em veículos.
- O Autor original do projeto é o Pottus, entretanto o seu projeto original não é atualizado à 6 anos, nosso objetivo é trazer essa versão 1.9d atualizada e melhorada.


# ❤️ Contruibuição
- Você também pode contruibuir com o projeto blu tanto nas traduções quanto na questão de adição de novos sistemas.


# 💻 Comandos disponíveis
### Mapas:
/loadmap - Carregamento do Mapa<br>
/newmap - Criamento do Mapa<br>
/importmap - Importar um mapa<br>
/export - Exportar um mapa<br>


### Objetos:
/cobject ou /co <objectid> - Criar um objeto<br>
/dobject ou /do - Deletar um objeto selecionado<br>
/robject - Redefine o texto e os materiais de um objeto<br>
/osearch - Procurar por objetos no Banco de Dados local<br>
/sel <objectid> - Selecionar um objeto pelo Índice<br>
/csel - Selecionar um objeto clicando nele<br>
/lsel - Use uma lista/visualização para exibir objetos<br>
/flymode ou /fm - Entrar no no-clip<br>
/ogoto - Teleportar o objeto selecionado (Você precisa estar em no-clip)<br>
/pivot - Defina uma posição de pivô para girar objetos<br>
/togpivot - Ativar/desativar a rotação do pivô<br>
/oprop - Editor de propriedades de objeto<br>

### Movimentação:
/editobject ou /eo - Editar modo de objeto<br>
/ox - /oy - /oz - Comandos de movimento padrão<br>
/rx - ry - /rz - Comandos de rotação padrão<br>
/dox - /doy - /doz - Mapa de movimento Delta<br>
/drx - /dry - /drz - Girar o mapa ao redor do centro do mapa<br>

### Texturas, Textos, Indexes e Temas:
/mtextures - Mostrar uma lista de texturas em uma lista<br>
/ttextures - Mostrar uma lista de texturas em (Tema)<br>
/stexture - Editor de textura<br>
/mtset <index> <textureref> - Definir um material<br>
/mtsetall <index> <textureref> - Defina um material para TODOS os objetos do mesmo modelid<br>
/mtcolor <index> <Hex Color ARGB> - Define uma cor de material<br>
/mtcolorall <index> <Hex Color ARGB> - Define uma cor de material para TODOS os objetos do mesmo modelid<br>
/copy - Copiar propriedades do objeto para buffer do objeto atualmente selecionado<br>
/paste - Colar propriedades do objeto do buffer no objeto atualmente selecionado<br>
/clear - Limpar propriedades do objeto do buffer<br>
/text - Abra o editor de texto do objeto<br>
/sindex - Definir texto em um objeto mostrará IDs de materiais<br>
/rindex - Remove índices de materiais mostrados em um objeto<br>
/loadtheme - Carregue um tema de textura<br>
/savetheme - Salva um tema de textura<br>
/deletetheme - Excluir um tema de textura<br>
/tsearch - Encontre uma textura por parte do nome<br>

### Grupos e Pré-fabricados:
/setgroup - Define um ID de grupo para objetos de grupo<br>
/selectgroup ou /sg - Selecione um grupo de objetos para editar<br>
/gsel - Abra clique em selecionar para adicionar/remover objetos do seu grupo<br>
/gadd - Adicione um objeto ao seu grupo útil para objetos que não podem ser clicados<br>
/grem - Remova um objeto específico do seu grupo<br>
/gclear - Limpe sua seleção de grupo<br>
/gclone - Clone sua seleção de grupo<br>
/gdelete - Exclua todos os objetos do seu grupo<br>
/editgroup ou /eg - Comece a editar um grupo<br>
/gox - /goy - /goz - Comandos de movimento de grupo padrão<br>
/gox - /goy - /goz - Comandos de rotação de grupo padrão<br>
/gaexport - Exporta um grupo de objetos para um objeto anexado FS (ainda não concluído)<br>
/gprefab - Exportar um grupo de objetos para um arquivo pré-fabricado carregável<br>
/prefabsetz - Definir o deslocamento de carga de um arquivo pré-fabricado<br>
/prefab <LoadName"> - Carregue um arquivo pré-fabricado, /prefab mostrará todos os pré-fabricados<br>
/0group - Isso moverá o centro de todos os objetos agrupados para 0,0,0, útil para obter deslocamentos de objetos anexados (ainda não está na GUI)<br>

### Veículos:
/avmodcar - Modifique um carro, ele teletransportará o veículo para a garagem mod correta, se modificável<br>
/avsetspawn - Defina a posição de spawn de um veículo<br>
/avnewcar - Crie um carro novo<br>
/avdeletecar - Exclua um carro indesejado<br>
/avcarcolor - Definir a cor do carro do veículo<br>
/avpaint - Defina uma pintura de veículos<br>
/avattach - Anexe o objeto atualmente selecionado ao veículo atualmente selecionado<br>
/avdetach - Desanexar o objeto atualmente selecionado do veículo<br>
/avsel - Selecione um veículo para editar<br>
/avexport - Exportar um carro para filterscript<br>
/avexportall - Exporte todos os carros para filterscript<br>
/avox - /avoy - /avoz - Comandos padrão de movimento de objetos de veículos<br>
/avrx - /avry - /avrz - Comandos padrão de rotação de objetos de veículos<br>
/avmirror - Espelhe o objeto atualmente selecionado no veículo<br>

### Binds:
/bindeditor - Abra o editor de bind, você pode inserir uma série de comandos para executar<br>
/runbind <index> - Executa uma bind<br>

### Outros:
/tpcoord <x> <y> <z> - Teleportar em uma posição<br>
/setint <interior id> - Alterar o interior<br>
/ir <playerid ou nick> - Teleportar em um jogador<br>
/thelp - Obter mais informações
