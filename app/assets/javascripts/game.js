$(function() {


});


var Game = function(element, playerType){

  this.element = $(element);

  this.init = function(){
    this.over = false;
    this.moves = 0;
    this._winPiece = [];
    this.startTime = Date.now();
    this.endTime = Date.now(); // reset this latter
    this.Player = [];
    this.Board = null;
    this.activePlayer = 0; // current active player (index of this.players)
    this.currentPlayer = (playerType == 'cross') ? 0 : 1;

    this.bindEvents()
  }

  this.bindEvents = function(){
    var self = this;

    $('#new-match', this.element).click(function(e){
      e.preventDefault();
      location.reload();
    });

    $('#restart', this.element).click(function(e){
      e.preventDefault();
      App.game.new_game();
      self.newGame();
    });

    // bind input actions
    $('#game tr td', this.element).click(function(el, a, b){
      if(self.over) return;
      if(self.activePlayer !== self.currentPlayer) return;
      var col = $(this).index();
      var row = $(this).closest('tr').index();
      App.game.take_turn(row +' '+ col);
      self.move( row +' '+ col );
    });

    $('#game tr td', this.element).hover(function(){
      if(self.activePlayer !== self.currentPlayer) return;
      if(self.over) return;
      $(this).addClass('hover-'+ self.activePlayer);
    }, function(){
      if(self.over) return;
      if(self.activePlayer !== self.currentPlayer) return;
      $(this).removeClass('hover-0 hover-1');
    })

    // reset the td.X|O elements when css animations are done
    $(this.element).on('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', 'td.X', function(){
      $(this).attr('class', 'X')
    });

    $(this.element).on('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', 'td.O', function(){
      $(this).attr('class', 'O')
    });

  };

  this.start = function(){
    this.init();
    // console.log('Starting Game');
    $('#game tr td').attr('class', '');
    this.getTurn();
    // create two players
    this.Player.push( new Player(0) );
    this.Player.push( new Player(1) );
    this.Board = new Board();
    this.Board.update();
    // set this.startTime
    this.startTime = Date.now();
  };

  this.newGame = function(element) {
    if (self.moves < 1) return;
    $('#restart').addClass('hidden');
    $('td.X, td.O', this.element).addClass('animated zoomOut')
    this.start();
  };

  this.getTurn = function() {
    if(this.over) return;
    if(this.activePlayer === this.currentPlayer) {
      $('#status').html('Your turn');
    } else {
      $('#status').html('Opponent\'s turn');
    }
  }

    /**
  * Parse a users move input string, e.g. '1 2'
  *
  * @param  {string} v An input string representing a move in the format 'row col'
  * @return {object}   row, col, and index (the index on the game board)
  */
  this.parseInput = function(v){
    v = v.split(' ');
    var pos = Number(v[1]);
    if(v[0] == 1) pos = (pos+3);
    if(v[0] == 2) pos = (pos+6);
    return {
      row: v[0],
      col: v[1],
      index: pos
    };
  };

    /**
  * Attempt to make a move, basically is it 'possible'
  *
  * @param  {number} input the index to move to
  * @return {boolean}
  */
  this.tryMove = function(input){
    if(this.Board.board[input] == '_') return true;
    return false;
  };

    /**
  * Make a move as the active player
  *
  * @param  {string} v An input string, eg: '1 1'
  * @return {boolean}   return false if we are unable to make the move
  */
  this.move = function(v){
    var Player = this.Player[ this.activePlayer ];
    v = this.parseInput(v);
    if(!this.tryMove(v.index)) return false;

    //console.log('%s: %s, %s', Player.symbol, v.row, v.col);

    Player.moves.push( v.index );
    this.moves++;
    this.Board.board[v.index] = Player.symbol;
    this.activePlayer = (Player._id) ? 0 : 1; // inverse of Player._id
    this.getTurn();
    // update our board.
    this.Board.update();

    // a player has won!
    if(this.hasWon(Player)){
      this.gameOver(Player);
      return true;
    }

    // draw!
    if(this.moves >= 9) this.gameOver(null)

    return true;
  };

  this.gameOver = function(Player){
    if (!Player) {
      $('td.X, td.O', this.element).addClass('animated swing');
      $('#restart').removeClass('hidden');
      $('#status').text('It\'s a Draw!').addClass('show');
      return true;
    }

    // only animate the winning pieces!
    var elements = '';
    for(var i=0; i<this._winPiece.length; i++){
      var p = this._winPiece[i]
      if (p < 3){
        elements += 'tr:eq(0) td:eq('+ p +'),';
      } else if( p < 6){
        elements += 'tr:eq(1) td:eq('+ (p-3) +'),';
      } else {
        elements += 'tr:eq(2) td:eq('+ (p-6) +'),';
      }
    }

    elements = elements.substring(0, elements.length - 1);

    var x = $( elements ).addClass('animated rubberBand')

    $('#status').text('Player '+ Player.symbol +' Wins!').addClass('show');
    $('#restart').removeClass('hidden');
    this.over = true;

  }

    /**
  * Check if the player has won
  * @param  {Player}  Player the player
  * @return {Boolean}
  */
  this.hasWon = function(Player){
    var won = false;
    var wins = Player.moves.join(' ');
    var self = this;

    this.Board.wins.each(function(n){
      if(wins.has(n[0]) && wins.has(n[1]) && wins.has(n[2])){
        won = true;
        self._winPiece = n;
        return true;
      }
    });
    return won;
  };


  //
  // Start the game
  //
  this.start()

};




/**
 * Player Object
 */
var Player = function(id, computer){
  this._id = id;
  this.symbol = (id == 0) ? 'X' : 'O';
  this.computer = (computer) ? computer : false; // default to computer user
  this.moves = [];
};



/**
 * Board Object
 */
var Board = function(){
  // empty board (3x3)
  this.board = [
    '_','_','_',
    '_','_','_',
    '_','_','_'
  ];

  // array of possible win scenarios
  this.wins = [
    [0,1,2], [3,4,5], [6,7,8], [0,3,6],
    [1,4,7], [2,5,8], [0,4,8], [2,4,6]
  ];

  this.update = function(){
    var board = this.board;
    $('#game tr').each(function(x, el){
      $('td', el).each(function(i, td){
        var pos = Number(i);
        if(x == 1) pos = (pos+3);
        if(x == 2) pos = (pos+6);
        var txt = (board[pos] == '_') ? '' : board[pos];
        $(this).html( txt ).addClass( txt );
      });
    });
  };

};
