-module( tdd_init ).

-export( [config/1] ).

config( gustav ) ->
	timer:sleep( 30000 ),
	[{gustav, 1}];

config( kalle ) ->
	timer:sleep( 30000 ),
	#{kalle1 => 1, kalle2 => 2}.

