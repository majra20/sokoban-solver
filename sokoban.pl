:-include(game).

solve(Problem, Solution):-
  Problem = [Tops, Rights, Boxes, Solutions, sokoban(Sokoban)],
  abolish_all_tables,
  retractall(top(_,_)),
  findall(_, ( member(P, Tops), assert(P) ), _),
  retractall(right(_,_)),
  findall(_, ( member(P, Rights), assert(P) ), _),
  retractall(solution(_)),
  findall(_, ( member(P, Solutions), assert(P) ), _),

  retractall(initial_state(_,_)),
  findall(Box, member(box(Box), Boxes), BoxLocs),
  assert(initial_state(sokoban, state(Sokoban, BoxLocs))),
  solve_dfs([pair(state(Sokoban, BoxLocs), [])], [], Solution).

solve_dfs([pair(State, _) | T], Visited, Solution) :-
  member(State, Visited),
  solve_dfs(T, Visited, Solution).

solve_dfs([pair(State, Moves) | _T], _Visited, Solution) :- 
  Solution = Moves,
  State = state(_, Boxes),
  all_boxes_in_solution(Boxes), !.

solve_dfs([pair(State, Moves) | T], Visited, Solution) :-
  not(member(State, Visited)),
  findall(X, solve_dfs_aux(pair(State, Moves), X), Xs),
  append(Xs, T, ToVisit),
  solve_dfs(ToVisit, [State | Visited], Solution).

solve_dfs_aux(pair(OldState, OldMoves), pair(NewState, NewMoves)) :-
  direction(Dir),
  movement(OldState, push(Box, Dir), MovesToBox),
  update(OldState, push(Box, Dir), NewState),
  NewState = state(NewSokoban, _),
  opposite_dir(Dir, OpDir),
  neib(NewSokoban, Lastt, OpDir),
  append(MovesToBox, [move(Lastt, Dir)], MovesWithPush),
  append(OldMoves, MovesWithPush, NewMoves).