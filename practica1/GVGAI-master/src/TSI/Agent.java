/*
 * [CASTELLANO]
 * Practica 1: Agente Deliberativo y Reactivo
 * Asignatura: Tecnicas de Sistemas Inteligentes
 * Autor: Valentino Lugli (Github: @RhinoBlindado)
 * Fecha: Marzo, Abril 2021
 */

/*
 * [ENGLISH]
 * Practice 1: Deliberative and Reactive Agent
 * Course: Intelligent Systems Techniques
 * Author: Valentino Lugli (Github: @RhinoBlindado)
 * Date: March, April 2021
 */

// Paquete perteneciente a 
package TSI;

// Librerias en uso
import java.util.ArrayList;
import java.util.Collections;
import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import ontology.Types.ACTIONS;
import tools.ElapsedCpuTimer;
import tools.Vector2d;

public class Agent extends AbstractPlayer
{
	Vector2d gridScale;
	Vector2d portalPos;
	Vector2d playerPos;
	Vector2d playerOrientation;
	
	ArrayList<ACTIONS> playerActions;
	int sizePlayerActions;
	ArrayList<node> open = new ArrayList<node>();
	ArrayList<node> closed = new ArrayList<node>();
	ArrayList<ACTIONS> road = new ArrayList<ACTIONS>();
	ArrayList<Observation>[][] worldMap;
	
	ACTIONS actAction;
	
	boolean hasPortal = false, 
			hasGems = false, 
			hasEnemies = false;
	
	ArrayList<Double>[][] heatMap;
	
	public Agent(StateObservation stateObs, ElapsedCpuTimer elapsedTimer)
	{
		gridScale = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length , 
        		stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);  
        
		// Obtener la posicion del agente, su orientacion y acciones.
		playerPos = stateObs.getAvatarPosition();
		playerPos.x = Math.floor(playerPos.x / gridScale.x);
		playerPos.y = Math.floor(playerPos.y / gridScale.y);
		
		playerOrientation = stateObs.getAvatarOrientation();
		
		playerActions = stateObs.getAvailableActions();
		sizePlayerActions = playerActions.size();
		
		// Obtener una captura del mapa.
		worldMap = stateObs.getObservationGrid();
		
        // Informacion de los recursos del mapa
		// 		Portales
        ArrayList<Observation>[] portalList = stateObs.getPortalsPositions(stateObs.getAvatarPosition());
        
        if(portalList != null)
        {
            portalPos = portalList[0].get(0).position;
            portalPos.x = Math.floor(portalPos.x / gridScale.x);
            portalPos.y = Math.floor(portalPos.y / gridScale.y);
            hasPortal = true;
        }

        //		Gemas
		if(stateObs.getResourcesPositions(stateObs.getAvatarPosition()) != null)
		{
			hasGems = true;
		}

		//		Enemigos
		ArrayList<Observation>[] enemyList = stateObs.getNPCPositions(stateObs.getAvatarPosition());
		if(enemyList != null)
		{
			hasEnemies = true;
		}
		
		// Comportamiento Deliberativo Sencillo
		if(hasPortal && !hasGems)
		{
		//	road = aStar(playerPos, portalPos, stateObs, elapsedTimer);
		}
		
		// Comportamiento Deliberativo Complejo	
		if(hasPortal && hasGems)
		{
			gemLocator(stateObs, elapsedTimer);
		}
		
		if(hasEnemies)
		{
			System.out.println(enemyList[0].get(0).position.toString());
		}
		
		
		System.out.println("WORLD SIZE IS: "+worldMap[0].length+" x "+worldMap.length);
		for(int i=0; i<worldMap.length; i++)
		{
			for(int j=0; j<worldMap[0].length; j++)
			{
				if(worldMap[i][j].size() > 0)
				{
					System.out.print(worldMap[i][j].get(0).itype+" ");
				}
				else
				{
					System.out.print("- ");
				}
			}
			System.out.print("\n");
		}
		

	}
	
	/**
	 * @brief Heuristic to calculate the weight of a node, uses Manhattan Distance.
	 * @param origin		2D Vector of the Point of Origin.
	 * @param destination	2D Vector of the Point of Destination.
	 * @return	Manhattan Distance from Origin to Destination
	 */
	public double manhattanDist(Vector2d origin, Vector2d destination)
	{
		return Math.abs(origin.x - destination.x) + Math.abs(origin.y - destination.y);
	}
	
	
	public ArrayList<Vector2d> aStar2(Vector2d origin, Vector2d destination, StateObservation stateObs, ElapsedCpuTimer elapsedTimer)
	{
		return null;
	}
	
	
	public ArrayList<ACTIONS> aStar(Vector2d origin, Vector2d destination, StateObservation stateObs, ElapsedCpuTimer elapsedTimer)
	{
		Vector2d actPos;
		Vector2d actOrientation;
		ACTIONS actAction;
		node actNode = null;
		boolean validNode;
		boolean sameOrientation;
		ArrayList<ACTIONS> theRoad = new ArrayList<ACTIONS>();
		
		boolean isOnClosed;
		boolean isOnOpen;
		
		open.clear();
		closed.clear();
		
		node root = new node(origin, playerOrientation, manhattanDist(origin, destination), new ArrayList<ACTIONS>());
		open.add(root);
		
	//	System.out.println("ORIGIN: "+ origin.toString()+" DESTINATION: "+ destination.toString());
		
		while(elapsedTimer.remainingTimeMillis() > 10)
		{
			//System.out.print(open.toString());
			actNode = open.get(0);

	//		System.out.println("ACT POS NODE: "+actNode.getPos().toString()+" | ORIENTATION: "+actNode.getOrientation().toString());
			
			
			// If node is on objective, stop.
			if( (actNode.getPos().x == destination.x) && (actNode.getPos().y == destination.y) )
			{
	//			System.out.println("Found!");
				break;
			}
			
			closed.add(actNode);
			open.remove(0);

			
			// Expand Current Node: Move to another tile in the map.
			//  - Loop starts at 1 because the 0th action is ACTION_USE.
			for(int i = 1; i < sizePlayerActions; i++)
			{
				validNode = false;
				actPos = new Vector2d (actNode.getPos());
				actOrientation = new Vector2d (actNode.getOrientation());
				sameOrientation = false;
				actAction = playerActions.get(i);
				
				
				if(actAction == ACTIONS.ACTION_UP)
				{
					actPos.y = actPos.y -1;
					
					if(actOrientation.y == -1)
					{
						sameOrientation = true;
					}
					actOrientation.x = 0;
					actOrientation.y = -1;
				}
				
				if(actAction == ACTIONS.ACTION_DOWN)
				{
					actPos.y = actPos.y + 1;
					
					if(actOrientation.y == 1)
					{
						sameOrientation = true;
					}
					
					actOrientation.x = 0;
					actOrientation.y = 1;
				}
				
				if(actAction == ACTIONS.ACTION_RIGHT)
				{
					actPos.x = actPos.x + 1;
					
					if(actOrientation.x == 1)
					{
						sameOrientation = true;
					}
					
					actOrientation.x = 1;
					actOrientation.y = 0;
				}

				if(actAction == ACTIONS.ACTION_LEFT)
				{
					actPos.x = actPos.x - 1;
					
					if(actOrientation.x == -1)
					{
						sameOrientation = true;
					}
					
					actOrientation.x = -1;
					actOrientation.y = 0;
				}
				
				if(worldMap[(int)actPos.x][(int)actPos.y].size() == 0)
				{
					validNode = true;
				}
				else if(worldMap[(int)actPos.x][(int)actPos.y].get(0).itype > 0)
				{
					validNode = true;
				}
				
				
				if(validNode)
				{
					
					theRoad = new ArrayList<ACTIONS>(actNode.getActionList());
					theRoad.add(actAction);
					
					if(!sameOrientation)
					{
						theRoad.add(actAction);
					}
					
					// Generate the new node.
					node newNode = new node(actPos, actOrientation, manhattanDist(actPos, destination), theRoad);
					
					isOnClosed = false;
					isOnOpen = false;
					
					// Check if newNode is in the closed list.
					for(int j = 0; j < closed.size(); j++)
					{
						if(newNode.getPos().equals(closed.get(j).getPos()))
						{
							isOnClosed = true;
							if(newNode.getAccumCost() < closed.get(j).getAccumCost())
							{
								open.add(closed.get(j));
								closed.remove(j);

							}
							break;
						}
					}
					
					if(!isOnClosed)
					{
						for(int j = 0; j < open.size(); j++)
						{
							if(newNode.getPos().equals(open.get(j).getPos()))
							{
								if(newNode.getAccumCost() < open.get(j).getAccumCost())
								{
									open.get(j).update(newNode);
								}
								isOnOpen = true;
								
								break;
							}
						}
					}
					
					if(!isOnOpen && !isOnClosed)
					{
						open.add(newNode);
					}
				}
			}
			Collections.sort(open);
		}
		
		playerOrientation = actNode.getOrientation();
		return actNode.getActionList();
	}
	
	
	public ArrayList<Vector2d> greedyTSP(ArrayList<Vector2d> gemList)
	{	
		ArrayList<Vector2d> gemRoad = new ArrayList<Vector2d>();
		Vector2d actualNode = playerPos;
		int counter = 0, bestNodeIndex = -1;
		double minDist, actDist;
				
		while(counter < 9)
		{
			minDist = Double.MAX_VALUE;
			for(int i = 0; i < gemList.size(); i++)
			{
				actDist = manhattanDist(actualNode,gemList.get(i));
				if(actDist < minDist)
				{
					minDist = actDist;
					bestNodeIndex = i;
				}
			}
			
			actualNode = gemList.get(bestNodeIndex);
			gemRoad.add(gemList.get(bestNodeIndex));
			gemList.remove(bestNodeIndex);
			
			counter++;
		}
		return gemRoad;
	}
	
	
	public void gemLocator(StateObservation stateObs, ElapsedCpuTimer elapsedTimer)
	{
		ArrayList<Observation>[] gemRawList = stateObs.getResourcesPositions(stateObs.getAvatarPosition());
		ArrayList<Vector2d> gemAuxList = new ArrayList<Vector2d>();
		
		for(int i=0; i < gemRawList[0].size(); i++)
		{
			gemAuxList.add(new Vector2d(Math.floor(gemRawList[0].get(i).position.x / gridScale.x), 
								  Math.floor(gemRawList[0].get(i).position.y / gridScale.y)));
		}
		
		ArrayList<Vector2d>gemList = greedyTSP(gemAuxList);
		
		Vector2d actGem = gemList.get(0);
		gemList.remove(0);
		
		road = aStar(playerPos, actGem, stateObs, elapsedTimer);	
		
		while(!gemList.isEmpty())
		{
			road.addAll( aStar(actGem, gemList.get(0), stateObs, elapsedTimer));
			actGem = gemList.get(0);
			gemList.remove(0);
		}
		road.addAll( aStar(actGem, portalPos, stateObs, elapsedTimer));
	
	}
	
	
	public double heat(Vector2d heatSrc, Vector2d position)
	{
		return Math.ceil(( 1 / ( (Math.pow( (position.x - heatSrc.x), 2) ) + (Math.pow((position.y - heatSrc.y), 2)) + 1 ) ) * 10);	
	}
	
	
	public Types.ACTIONS evasion(StateObservation stateObs)
	{
		ArrayList<ArrayList<Double>> heatMap = new ArrayList<>();
		
		for(int i=0; i<worldMap.length; i++)
		{
			heatMap.add(new ArrayList<>());
			for(int j=0; j<worldMap[0].length; j++)
			{
				heatMap.get(i).add(0.0);
				if(worldMap[i][j].size() != 0)
				{
					if(worldMap[i][j].get(0).itype == 0)
					{
						heatMap.get(i).set(j, 100.0);
					}
				}
			}
		}
		

		
		ArrayList<Observation>[] enemy = stateObs.getNPCPositions();
		ArrayList<Vector2d> enemyPos = new ArrayList<Vector2d>();
		
		for(int i=0; i < enemy[0].size(); i++)
		{
			enemyPos.add(new Vector2d(enemy[0].get(i).position.x / gridScale.x, enemy[0].get(i).position.y / gridScale.y));
		}
		
		int actX;
		int actY;
		
		for(int i=0; i < enemyPos.size(); i++)
		{
			actX = (int)enemyPos.get(i).x;
			actY = (int)enemyPos.get(i).y;
			
		//	System.out.println("ENEMY IN "+ actX+" "+actY);
			
			for(int j=actX-4; j < actX+4; j++)
			{
				if(j >= 0 && j < worldMap.length)
				{
					for(int k=actY-4; k < actY+4; k++)
					{
						if(k >= 0 && k < worldMap[0].length) 
						{
							heatMap.get(j).set(k, heatMap.get(j).get(k) + heat(enemyPos.get(i), new Vector2d(j, k)));
						}
					}
				}
			}
			
		}
		
		for(int i=0; i<worldMap.length; i++)
		{
			for(int j=0; j<worldMap[0].length; j++)
			{
				System.out.print(heatMap.get(i).get(j)+"\t");
			}
			System.out.print("\n");
		}
		
		System.out.print("\n--------\n");
	
		double actDanger = heatMap.get((int)playerPos.x).get((int)playerPos.y);
		ACTIONS react = ACTIONS.ACTION_NIL;
		
		System.out.println("ACT DANGER: "+actDanger);
		if(actDanger > 3)
		{
			if(heatMap.get(((int)playerPos.x)).get((int)playerPos.y) < actDanger)
			{
				react = ACTIONS.ACTION_UP;
			}
			
			if(heatMap.get(((int)playerPos.x)-1).get((int)playerPos.y) < actDanger)
			{
				react = ACTIONS.ACTION_DOWN;
			}
			
			if(heatMap.get(((int)playerPos.x)).get((int)playerPos.y+1) < actDanger)
			{
				react = ACTIONS.ACTION_LEFT;

			}
			
			if(heatMap.get(((int)playerPos.x)+1).get((int)playerPos.y-1) < actDanger)
			{
				react = ACTIONS.ACTION_RIGHT;
			}
		}
		
		return react;	
	}
	
	
	public Types.ACTIONS act(StateObservation stateObs, ElapsedCpuTimer elapsedTimer)
	{
		if (!road.isEmpty())
		{
			actAction = road.get(0);
			road.remove(0);
		}
		else
		{
			actAction = ACTIONS.ACTION_NIL;
		}
		
		if(hasEnemies)
		{
			actAction = evasion(stateObs);
		}
		
		return actAction;	
	}
}