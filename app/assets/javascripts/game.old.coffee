##
## Document Ready, Let's Play
##

#$ ->
  #new Game('#game-container')
  #return

#Game = (element) ->
  #@element = $(element)

  #@init = ->
    #@over = false
    #@moves = 0
    #@_winPiece = []
    #@startTime = Date.now()
    #@endTime = Date.now()
    ## reset this latter
    #@Player = []
    #@Board = null
    #@activePlayer = 0
    ## current active player (index of this.players)
    #@updateMovesCount()
    #@maxThemes = 4
    #@bindEvents()
    #return

  #@bindEvents = ->
    #self = this
    #$('#restart', @element).click (e) ->
      #e.preventDefault()
      #if self.moves < 1
        #return
      #self.hideMenu()
      #$('td.X, td.O', @element).addClass 'animated zoomOut'
      #setTimeout (->
        #self.restart()
        #return
      #), 750
      #return
    ## bind input actions
    #$('#game tr td', @element).click (el, a, b) ->
      #if self.over
        #return
      #col = $(this).index()
      #row = $(this).closest('tr').index()
      #console.log row + ' ' + col
      #self.move row + ' ' + col
      #self.showMenu()
      #return
    #$('#game tr td', @element).hover (->
      #if self.over
        #return
      #$(this).addClass 'hover-' + self.activePlayer
      #return
    #), ->
      #if self.over
        #return
      #$(this).removeClass 'hover-0 hover-1'
      #return
    ## reset the td.X|O elements when css animations are done
    #$(@element).on 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', 'td.X', ->
      #$(this).attr 'class', 'X'
      #return
    #$(@element).on 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', 'td.O', ->
      #$(this).attr 'class', 'O'
      #return
    #return

  #@start = ->
    #@hideMenu()
    #@init()
    ## console.log('Starting Game');
    #$('#game tr td').attr 'class', ''
    #$('#status').removeClass 'show'
    ## create two players
    #@Player.push new Player(0)
    #@Player.push new Player(1)
    #@Board = new Board
    #@Board.update()
    ## set this.startTime
    #@startTime = Date.now()
    ## this.timer();
    #return

  #@showMenu = ->
    #$('#menu').attr 'class', ''
    #return

  #@hideMenu = ->
    #$('#menu').attr 'class', 'hidden'
    #return

  #@restart = ->
    #clearInterval @timerHandle
    #@start()
    #return

  #@timer = ->
    #self = this
    #thens = self.startTime

    #format = (now, thens) ->
      #Date.create(thens).relative()

    #@timerHandle = setInterval((->
      #now = Date.now()
      #$('#time').text format(now, thens)
      #return
    #), 500)
    #return

  ####*
  ## Parse a users move input string, e.g. '1 2'
  ##
  ## @param  {string} v An input string representing a move in the format 'row col'
  ## @return {object}   row, col, and index (the index on the game board)
  ####

  #@parseInput = (v) ->
    #v = v.split(' ')
    #pos = Number(v[1])
    #if v[0] == 1
      #pos = pos + 3
    #if v[0] == 2
      #pos = pos + 6
    #{
      #row: v[0]
      #col: v[1]
      #index: pos
    #}

  ####*
  ## Attempt to make a move, basically is it 'possible'
  ##
  ## @param  {number} input the index to move to
  ## @return {boolean}
  ####

  #@tryMove = (input) ->
    ##console.log input
    #if @Board.board[input] == '_'
      #return true
    #false

  ####*
  ## Make a move as the active player
  ##
  ## @param  {string} v An input string, eg: '1 1'
  ## @return {boolean}   return false if we are unable to make the move
  ####

  #@move = (v) ->
    #Player = @Player[@activePlayer]
    #v = @parseInput(v)
    #if !@tryMove(v.index)
      #return false
    #console.log('%s: %s, %s', Player.symbol, v.row, v.col);
    #Player.moves.push v.index
    #@moves++
    #@Board.board[v.index] = Player.symbol
    #@activePlayer = if Player._id then 0 else 1
    ## inverse of Player._id
    ## update our board.
    #@Board.update()
    #@updateMovesCount()
    ## a player has won!
    #if @hasWon(Player)
      #@gameOver Player
      #return true
    ## draw!
    #if @moves >= 9
      #@gameOver null
    #true

  #@gameOver = (Player) ->
    #if !Player
      #$('td.X, td.O', @element).addClass 'animated swing'
      #return $('#status').text('It\'s a Draw!').addClass('show')
    ## only animate the winning pieces!
    #elements = ''
    #i = 0
    #while i < @_winPiece.length
      #p = @_winPiece[i]
      #if p < 3
        #elements += 'tr:eq(0) td:eq(' + p + '),'
      #else if p < 6
        #elements += 'tr:eq(1) td:eq(' + p - 3 + '),'
      #else
        #elements += 'tr:eq(2) td:eq(' + p - 6 + '),'
      #i++
    #elements.slice 0, -1
    ## trim last character
    #x = $(elements).addClass('animated rubberBand')
    #$('#status').text('Player ' + Player.symbol + ' Wins!').addClass 'show'
    #@over = true
    #return

  ####*
  ## Check if the player has won
  ## @param  {Player}  Player the player
  ## @return {Boolean}
  ####

  #@hasWon = (Player) ->
    #won = false
    #wins = Player.moves.join(' ')
    #self = this
    #@Board.wins.each (n) ->
      #if wins.has(n[0]) and wins.has(n[1]) and wins.has(n[2])
        #won = true
        #self._winPiece = n
        #return true
      #return
    #won

  #@updateMovesCount = ->
    #$('#time').text 'Moves: ' + @moves
    #return

  ##
  ## Start the game
  ##
  #@start()
  #return

####*
## Player Object
####

#Player = (id, computer) ->
  #@_id = id
  #@symbol = if id == 0 then 'X' else 'O'
  #@computer = if computer then computer else true
  ## default to computer user
  #@moves = []
  #return

####*
## Board Object
####

#Board = ->
  ## empty board (3x3)
  #@board = [
    #'_'
    #'_'
    #'_'
    #'_'
    #'_'
    #'_'
    #'_'
    #'_'
    #'_'
  #]
  ## array of possible win scenarios
  #@wins = [
    #[
      #0
      #1
      #2
    #]
    #[
      #3
      #4
      #5
    #]
    #[
      #6
      #7
      #8
    #]
    #[
      #0
      #3
      #6
    #]
    #[
      #1
      #4
      #7
    #]
    #[
      #2
      #5
      #8
    #]
    #[
      #0
      #4
      #8
    #]
    #[
      #2
      #4
      #6
    #]
  #]

  #@update = ->
    #board = @board
    #$('#game tr').each (x, el) ->
      #$('td', el).each (i, td) ->
        #pos = Number(i)
        #if x == 1
          #pos = pos + 3
        #if x == 2
          #pos = pos + 6
        #txt = if board[pos] == '_' then '' else board[pos]
        #$(this).html(txt).addClass txt
        #return
      #return
    #return

  #return
