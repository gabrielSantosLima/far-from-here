# Far From Here

Roguelike de ação naval (PvE), isométrico 2D pixelado, feito em **Godot 4.7**.
Baseado no `GDD - Far From Here.pdf` — Capitão Piteu, canhões, gestão de energia/fadiga
e o ciclo de sono forçado.

## História

*(baseada no `GDD - Far From Here.pdf`)*

O lendário pirata **Capitão Piteu** acumulou tesouros incalculáveis em anos de
pilhagem, mas foi atingido por uma maldição ancestral: a **Nóvoa de Morfeu**, uma
sonolência mística incontrolável. A caminho da aposentadoria numa ilha pacífica,
ele adentrou inadvertidamente o **Mar Ancestral**, uma região dominada pela
**Frota Espectral** — piratas mortos-vivos que, aproveitando seus acessos de sono
profundo, roubaram suas **relíquias mágicas** e espalharam seu ouro pelo
**Arquipélago dos Espectros**.

Preso num ciclo infinito de névoa e perigo, Piteu precisa atravessar o
arquipélago, afundar os navios assombrados, reunir as relíquias e romper o feitiço
— e só assim encontrar o repouso merecido.

A **cutscene inicial** resume essa história em 4 quadros: *as riquezas → o
adormecer → a chegada dos inimigos → a vingança* (`parte_1_riquezas.png` ...
`parte_4_vinganca.png`).

## Controles

| Tecla | Ação |
|---|---|
| `W` / `↑` | Acelerar (ajustar o pano da vela) |
| `S` / `↓` | Desacelerar / dar ré |
| `A` / `←` | Bombordo (virar à esquerda) |
| `D` / `→` | Estibordo (virar à direita) |
| `Shift` | Boost de velocidade (custa 5 de energia) |
| Mouse | Mirar (crosshair) |
| Botão esquerdo | Atirar bola de canhão |
| `Espaço` / `Enter` | Avançar menu/cutscene; reiniciar (game over); voltar ao menu (vitória) |
| `M` | Ligar/desligar a música |

## Mecânicas principais

- **Navegação e leme**: o jogador ajusta a vela (acelerar/ré) e vira o leme
  (bombordo/estibordo) ao mesmo tempo; o oceano é uma grade 7×7 que segue a
  câmera, simulando mar "infinito".
- **Energia, fadiga e sono (mecânica core)**: o capitão tem **10 de energia**;
  cada tiro custa **1** e o boost custa **5**. A energia recarrega **1 ponto a
  cada 2 s**. Se zerar, ele **dorme por 3 s**: fica imóvel, um rótulo **"Zzz"**
  aparece e, ao acordar, a energia volta ao máximo.
- **Boost de velocidade**: `Shift` dá um pico de velocidade (×1,8 durante 2 s)
  ao custo de 5 de energia.
- **Combate de canhão**: as bolas viajam devagar descrevendo um arco e a **sombra
  marca o ponto de queda** — dá tempo de desviar. Cadência de 0,7 s; os inimigos
  revidam e o **boss dispara 3 canhões** em leque.
- **Fogo**: de perto, os espectros usam **lança-chamas** com queimadura; o boss
  enraivecido solta uma **explosão de fogo radial**.
- **IA dos inimigos**: os navios ficam inertes até o jogador entrar no raio de
  detecção; então perseguem, atiram e trocam a música para a de batalha
  (desistem se o jogador fugir do alcance).
- **Vidas e consequências**: jogador e boss têm **10 PV**, inimigos comuns **3**.
  Afundar o jogador leva ao **game over**; destruir toda a frota leva à **vitória**.
- **Minimapa**: mostra o jogador (verde), inimigos (vermelho), boss (magenta) e a
  área visível (retângulo branco).

## Escopo atual

Apenas **1 fase (Fase 1)**:
- O barco do jogador começa no meio do mar.
- À frente: **3 barcos inimigos** + **1 barco boss** (mais forte).

## Cutscene inicial

`scenes/Historia.tscn` (`scripts/historia.gd`) é a **cena principal** do projeto:
mostra 4 quadros (`parte_1_riquezas.png` ... `parte_4_vinganca.png`) centralizados
sobre fundo preto, com **fade de 0,8 s** entre eles. Cada quadro fica **5 s** e o
**último 8 s**. Toca `historia.mp3`; ao terminar, faz o fade para a tela inicial e
troca a música para o tema (`FarFromHereTheme.mp3`).

## Tela inicial

`scenes/TelaInicial.tscn`: fundo de oceano escurecido,
a logo `FarFromHereLogo.png` ao centro (com animação de "respiração" na escala) e a
mensagem `PressSpaceToPlay.png` (menor, com fade pulsante).

Ao pressionar **Espaço** (ou Enter): a logo dá um "soco" de escala, um flash branco
aparece, o autoload `Transicao` faz **fade out -> troca de cena -> fade in** e a
música faz **crossfade** do tema para `navegando.mp3` (`scripts/tela_inicial.gd`).

## Cena da Fase 1

`scenes/Fase1.tscn` (1280x720, filtro *Nearest*).
Mapa de **4800 x 3200** px — o jogador começa bem longe da frota inimiga.

```
Fase1 (Node2D)
├─ Oceano (Node2D)              # scripts/oceano.gd — grade 7x7 que segue a câmera (mar "infinito")
│   └─ Agua_x_y ...             # AnimatedSprite2D (21 frames), tiles 342x180 com leve sobreposição
├─ BarcoJogador (Node2D)        # scripts/jogador.gd (Barco) — ship (1), vela creme
│   ├─ Sprite2D
│   ├─ Esteira (CPUParticles2D) # rastro de espuma quando navega
│   └─ Camera2D                 # segue o jogador, limitada aos 4800x3200
├─ Inimigo1 (Node2D)            # scripts/inimigo.gd — ship (2), vela cinza com caveira
├─ Inimigo2 (Node2D)            # scripts/inimigo.gd — ship (10), vela verde rasgada
├─ Inimigo3 (Node2D)            # scripts/inimigo.gd — ship (5), vela azul
├─ Boss (Node2D)                # scripts/inimigo.gd (is_boss) — ship (3), escala 2.0
├─ Mira (Node2D)                # scripts/mira.gd — crosshair na posição do mouse
└─ HUD (CanvasLayer)
    ├─ Minimapa (Control)       # scripts/minimapa.gd
    ├─ BarraJogador (Control)   # scripts/barra_vida.gd — vida do jogador
    ├─ BarraChefe (Control)     # scripts/barra_vida.gd — vida do boss (combate)
    └─ ControleAudio            # botão de som + volume
```

A cena é gerada por `tools/build_fase1.gd` (Godot headless) e pode ser editada no editor.

### Tiro de canhão

- `scripts/mira.gd`: crosshair desenhado na posição do mouse (nó `Mira`). O
  cursor do sistema fica **escondido** durante a fase (volta a aparecer no menu,
  no game over e na vitória).
- `scripts/jogador.gd`: botão esquerdo cria uma bola (`scenes/BalaCanhao.tscn`)
  que parte da proa e viaja até a mira (cadência 0,7 s) com flash de disparo.
- `scripts/bala_canhao.gd`: projétil com **física/inércia** — viaja devagar
  (`shot_speed` ~330 px/s do jogador, 260 px/s dos inimigos) descrevendo um arco
  de altura, então dá tempo de desviar. Uma **sombra fica parada no ponto de
  queda** indicando onde a bola vai cair. O dano é aplicado na aterrissagem.
- **Inimigos também atiram**: quando alertados, disparam a cada `fire_cooldown`
  (2,4 s) mirando a posição do jogador. O **boss tem 3 canhões** (3 bolas em leque).
- **Vidas**: inimigos comuns têm **3**, o boss **10** (`max_hp`) e o jogador
  **10** (`jogador.gd`). Ao zerar, o navio afunda (fade + explosão) e sai do
  combate; se o **jogador** zerar, o jogo termina na tela de **game over**.
- `scripts/barra_vida.gd`: barras genéricas — `BarraJogador` (sempre visível,
  canto superior esquerdo) e `BarraChefe` (topo, só durante o combate).

### Energia do capitão e sono

`scripts/jogador.gd`: o capitão tem **10 de energia** (`max_energia`). Cada tiro
gasta **1** (`custo_tiro`); a energia **recarrega 1 ponto a cada 2 s**
(`energia_recarga`). Se a energia **zerar**, o capitão **dorme por 3 s**
(`sono_duracao`): fica **imóvel** (não navega nem atira), surge um rótulo **"Zzz"**
acima do barco e, ao acordar, a energia volta ao máximo.
- **Boost**: `Shift` acelera a vela por `boost_duracao` (**2 s**, ×`boost_multiplicador`
  1,8) e custa **5 de energia** (`boost_custo`). Sem energia suficiente o boost não
  dispara; se a energia zerar com o boost, o capitão dorme na sequência.
- `scripts/barra_energia.gd`: `BarraEnergia` no HUD, logo abaixo da vida
  (amarela, com espaço entre as duas), mostra a energia atual.

### Game over

Quando a vida do Capitão Piteu zera, `jogador.gd` (`_morrer`) dispara um flash
vermelho + fade via `Transicao` para `scenes/GameOver.tscn`
(`scripts/gameover.gd`): a imagem `gameover.png` aparece centralizada sobre um
fundo preto (com margem). Toca a música `gameover.mp3` e, ao apertar **Espaço**
(ou Enter), reinicia a **Fase 1**, voltando a música para `navegando.mp3`.

### Vitória

Quando o último inimigo/boss afunda, `inimigo.gd` (`_checar_vitoria`) detecta que
não resta ninguém vivo e chama `jogador.vencer()`: flash dourado + fade para
`scenes/Vitoria.tscn` (`scripts/vitoria.gd`), com `win.png` centralizado sobre
fundo preto (com margem) e a música-tema. Apertar **Espaço** (ou Enter) volta
para a **tela inicial**.

### Lança-chamas dos inimigos

De perto, os inimigos disparam um lança-chamas (`inimigo.gd`): alcance
`flame_range` (**195 px**), dano contínuo `flame_dps` (**1/s**) e queimadura
`burn_duration` (**2,5 s**, 1 de dano por segundo). O boss enraivecido usa um golpe
radial (`_nova_burst`, dano **1**).

### IA dos inimigos

`scripts/inimigo.gd` (base `scripts/barco.gd`): os navios ficam parados até o
jogador entrar no **raio de detecção** (`detect_radius`, 900 px nos comuns e
1400 px no boss). Ao detectar, passam a mirar e perseguir a posição do jogador,
**atiram bolas de canhão** e disparam a **música de batalha**. Se o jogador se afastar além de
`give_up_radius` (1500 px nos comuns, 2400 px no boss), o inimigo **desiste** e,
quando nenhum inimigo está em combate, a música calma volta. Velocidade máxima
dos inimigos: **115 px/s** (`enemy_max_speed`; o boss usa 70% disso) — mais lenta
que a do jogador (230 px/s). Todos os barcos balançam e deixam esteira ao navegar.

### Minimapa

`scripts/minimapa.gd` desenha, no canto superior direito, o retângulo do mapa
(4800x3200) com: ponto verde = jogador, pontos vermelhos = inimigos, ponto
magenta = boss, e o retângulo branco = área visível (estilo Age of Empires).

### Áudio

- `scripts/audio.gd` é um **autoload** (`Audio`) que toca `FarFromHereTheme.mp3`
  no menu e faz **crossfade** para `navegando.mp3` ao iniciar o jogo (dois
  players alternados). Controla volume/mudo.
- **Música de batalha**: quando qualquer inimigo aggrava, ele chama
  `Audio.enter_combat()` e a faixa faz crossfade para `batalha.mp3`; quando o
  último inimigo desiste (`give_up_radius`), `Audio.exit_combat()` volta para a
  música calma (`navegando.mp3`). Contador `_combat` evita cortes com vários
  inimigos.
- `scenes/ControleAudio.tscn` (`scripts/controle_audio.gd`): botão com **ícone de
  som** (`assets/ui/som_on.png` / `som_off.png`, gerados no projeto) + slider de
  volume, no canto inferior esquerdo do menu e do HUD da fase.
- Atalho global **M** para alternar o mudo (`Audio._unhandled_input`).
- `scripts/transicao.gd` é o **autoload** (`Transicao`): fade out/in entre cenas
  e flash branco, desenhado acima de tudo (`layer = 128`).

### Estado do mundo

`scripts/mapa.gd` é uma **classe estática global** (`class_name Mapa`) com
`rect` (limites do mapa) e `jogador` (referência). `Mapa.clamp_pos()` limita os
barcos ao mapa e `Mapa.ensure_input()` registra as ações de input.

## Estrutura de assets

```
assets/
├─ navios/     # cascos, canhão e explosão (recorte do Kenney Pirate Pack)
├─ ambiente/   # oceano tileável animado (ocean01..21)
├─ ui/         # ícones de som (som_on / som_off)
└─ vfx/        # partículas (flame, circle)
```

## Relação de assets (somente o que é usado)

| Grupo | Pasta | Pack | Autor | Licença | Conteúdo |
|---|---|---|---|---|---|
| Navios | `assets/navios/PNG/Default size/Ships/` | [Pirate Pack](https://kenney.nl/assets/pirate-pack) | Kenney | CC0 | `ship (1,2,3,5,10).png` — jogador, inimigos e boss |
| Navios (efeitos) | `assets/navios/PNG/Default size/Effects/` | Pirate Pack | Kenney | CC0 | `explosion1.png` |
| Navios (partes) | `assets/navios/PNG/Default size/Ship parts/` | Pirate Pack | Kenney | CC0 | `cannonBall.png` |
| Ambiente | `assets/ambiente/oceano_tileavel/` | [The Battle for Wesnoth water animation](https://opengameart.org/content/the-battle-for-wesnoth-water-animation) | zookeeper + Zabin | CC0 | `ocean01..21.png` (342x180) — oceano profundo tileável; `oceano_spriteframes.tres` é a animação montada |
| VFX | `assets/vfx/PNG (Transparent)/` | [Particle Pack](https://kenney.nl/assets/particle-pack) | Kenney | CC0 | `circle_05.png` (esteira/sombra) e `flame_01.png` (fogo/lança-chamas) |
| UI (ícones) | `assets/ui/` | (projeto) | — | — | `som_on.png`, `som_off.png` do controle de volume |
| Cutscene | raiz do projeto | `parte_1_riquezas.png` ... `parte_4_vinganca.png` | (projeto) | — | Quadros da cutscene inicial |
| Música (cutscene) | raiz do projeto | `historia.mp3` | (projeto) | — | Tocado na cutscene inicial |
| Música (menu) | raiz do projeto | `FarFromHereTheme.mp3` | (projeto) | — | Tema tocado no menu, em loop |
| Música (jogo) | raiz do projeto | `navegando.mp3` | (projeto) | — | Tema calmo da navegação, em loop |
| Música (batalha) | raiz do projeto | `batalha.mp3` | (projeto) | — | Tocado quando inimigos aggram; volta ao calmo quando desistem |
| Música (game over) | raiz do projeto | `gameover.mp3` | (projeto) | — | Tocado na tela de game over |

> Os packs originais foram recortados para conter apenas os arquivos usados; os
> `.zip` e os arquivos não referenciados foram removidos do repositório.

## Licenças e atribuições

- **CC0** (Kenney, Foozle) — uso livre, inclusive comercial; atribuição não obrigatória.
- **CC-BY-SA 3.0** (oceano, Zabin/Len) — uso livre com **crédito** a
  *Leonard Pabin (Len)* e *Zachariah Husiar (Zabin)* e mantendo a mesma licença em
  edições do asset. O asset é dual-licenciado com GPL 3.0.
- Créditos sugeridos no jogo: *"Ocean tiles by Zabin & Leonard Pabin (CC-BY-SA 3.0)"*.

## Pendências / próximos assets

- **Navio boss** (Almirante Espectral) e variações de inimigos — recolorir CC0 (Foozle/Kenney) ou usar módulos isométricos do pack monogon (CC-BY-ND).
- **Fragmentos de relíquia / saque** (pixel art) e ícones de relíquia.
- **Música-tema** pirata (ex.: packs do alkakrab no itch.io).
- **Efeito sonoro de canhão / afundamento / sono (Zzz)** — Impact Sounds cobre parcialmente.
- **Navios com direção isométrica** — `Free Pixelart Boats (16 direções)` (@pixel_Salvaje) ainda não baixado.
