# Aplicação de Monitoramento de Automóveis com GeoFencing e detecção de acidentes utilizando os acelerômetros.

## Executando o projeto

__Flutter (/geo_app)__ 
- Primeiro execute `flutter pub get` para instalar as dependências do flutter. 
- Inicie o emulador e execute 'Run without debugging'.

__Python (/server)__
- Crie um ambiente virtual e instale as dependências `pip install -r requirements.txt`.
- execute em diferentes terminais os arquivos /mosquitto.
- execute o servidor flask `flask --app server run`. 

> O servidor será executado em: http://127.0.0.1:5000