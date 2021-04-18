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
package src_lugli__valentino;

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
	/*
	 * - gridScale almacena la escala del mapa.
	 * - portalPos almacena las coordenadas del portal.
	 * - playerPos almacena las coordnadas del jugador en cada tick.
	 * - playerOrientation almacena la orientación en cada tick.
	 */
	Vector2d gridScale,
			 portalPos,
			 playerPos,
			 playerOrientation;
	
	/*
	 * - playerActions almacena las acciones del personaje, se utiliza en el A* para legibilidad.
	 * - open mantiene la lista de nodos en ABIERTOS
	 * - closed mantiene la lista de nodos CERRADOS
	 * - road almacena la ruta que el avatar ha de hacer.
	 * - worldMap mantiene una captura del mapa, utilizada para detectar los muros.
	 * - gemRawList almacena la información en bruto de las gemas del mapa.
	 * - heatMap almacena un mapa de calor de los enemigos y los muros del mapa.
	 */
	ArrayList<ACTIONS> playerActions;
	ArrayList<node> open = new ArrayList<node>();
	ArrayList<node> closed = new ArrayList<node>();
	ArrayList<ACTIONS> road = new ArrayList<ACTIONS>();
	ArrayList<Observation>[][] worldMap;
	ArrayList<Observation>[] gemRawList;
	ArrayList<ArrayList<Double>> heatMap = new ArrayList<>();

	// actAction se utiliza por legibilidad en el método act.
	ACTIONS actAction;
	
	boolean hasPortal = false, 
			hasGems = false, 
			hasEnemies = false,
			hasRouteToGem = false,
			hasRouteToPortal = false;
	
	/* 
	 * - sizePlayerActions mantiene el tamaño de la lista playerActions, se utiliza en el A* por legibilidad.
	 * - internalGemCount mantiene una cuenta interna de las gemas que ya se han planificado para obtener,
	 *   puede diferir de la cantidad actual de gemas porque es un método interno utilizado en la planificación.
	 * - dangerRadius indica el radio alrededor del enemigo donde se genera el mapa de calor.
	 */
	int sizePlayerActions,
		internalGemCount = 0,
		dangerRadius = 0;
	
	// Mantiene el peligro actual del Avatar.
	double actDanger = 0.0;
	

	public Agent(StateObservation stateObs, ElapsedCpuTimer elapsedTimer)
	{
		// Obtener la escala del mundo.
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

        // Chequear si hay gemas en el mapa
		if(stateObs.getResourcesPositions(stateObs.getAvatarPosition()) != null)
		{
			hasGems = true;
		}

		// Chequear si hay enemigos en el mapa.
		if(stateObs.getNPCPositions(stateObs.getAvatarPosition()) != null)
		{
			hasEnemies = true;
			dangerRadius = 4;
			
			// Si no hay gemas, agrandar el radio del mapa de calor.
			if(!hasGems)
				dangerRadius = 10;
		}
				
		/* 
		 * Si hay un portal, no hay gemas y no hay enemigos entonces se está en un mapa deliberativo simple.
		 * Entonces, calcular la ruta de una vez aprovechando el tiempo de sobra.
		 */ 
		if(hasPortal && !hasGems && !hasEnemies)
		{
			road = aStar(playerPos, portalPos, stateObs, elapsedTimer);
		}
		
		/*
		 * Si hay portal, hay gemas y no hay enemigos entonces se está en un mapa deliberativo compuesto.
		 * Entonces, calular la ruta hacia las gemas aprovechando el tiempo de sobra. 
		 */
		if(hasPortal && hasGems && !hasEnemies)
		{
			gemLocator(stateObs, elapsedTimer);
		}
		
		/*
		 * En el caso de haber enemigos, entonces es mejor generar las rutas una vez que se ha verificado que no hay
		 * ningún enemigo cerca, por lo tanto este paso se realiza en la función "act".
		 */
		
	}
	
	/**
	 * @brief Calcular la distancia Manhattan entre dos puntos.
	 * @param origin		Vector 2D de la posición de origen.
	 * @param destination	Vector 2D de la posición de destino
	 * @return	Distancia Manhattan
	 */
	public double manhattanDist(Vector2d origin, Vector2d destination)
	{
		return Math.abs(origin.x - destination.x) + Math.abs(origin.y - destination.y);
	}
	
	/**
	 * @brief Obtener una ruta de un punto A a un punto B utilizando el Algoritmo A*
	 * @param origin		Vector2D de la posición de origen-
	 * @param destination	Vector2D de la posición de destino.
	 * @param stateObs		Observaciones
	 * @param elapsedTimer	Temporizador
	 * @return	Lista de Acciones que contiene la ruta óptima
	 */
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
		
		// Si sucede un time-out antes de la ejecución del algoritmo, devolver al menos una ruta nula.
		actNode = root;
		
		// Mientras quede tiempo...
		while(elapsedTimer.remainingTimeMillis() > 10)
		{
			actNode = open.get(0);			
			
			// Si el nodo sacado de abiertos es igual que el destino, parar.
			if( actNode.getPos().equals(destination) )
			{
				// Si el destino es el portal, marcarlo.
				if(destination.equals(portalPos))
				{
					hasRouteToPortal = true;
				}
				else
				{
					// Si no lo es, es una gema, rellenar el contador de gemas interno.
					internalGemCount++;
					
					// Si ya es la novena gema, entonces ya se tiene el camino entero.
					if(internalGemCount == 9)
					{
						hasRouteToGem = true;
					}
				}
				break;
			}
			
			closed.add(actNode);
			open.remove(0);

			
			/*
			 * - Expandir el nodo actual, esto se puede interpretar como moverse una casilla hacia arriba, abajo,
			 * izquierda o derecha. Esto también equivale a utilizar las acciones equivalentes que posee el personaje.
			 * 
			 * - El bucle comienza en 1 ya que la acción 0 es la de USAR, la cual no va a ser utilizada.
			 */
			for(int i = 1; i < sizePlayerActions; i++)
			{
				// Preparar los datos para el nodo hijo.
				validNode = false;
				actPos = new Vector2d (actNode.getPos());
				actOrientation = new Vector2d (actNode.getOrientation());
				sameOrientation = false;
				actAction = playerActions.get(i);
				
				//	Dependiendo de para dónde se está dirigiendo, modificar la posición y orientación respecto a lo actual.
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
				
				// Verificar que el movimiento es válido, es decir que esa casilla está vacía o bien no es un muro.
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
					// Generar la ruta a medida que se expanden los nodos; obtener el camino hasta el nodo padre y añadir la acción
					// que ha llevado hasta este nodo.
					theRoad = new ArrayList<ACTIONS>(actNode.getActionList());
					theRoad.add(actAction);
					
					// Si la orientación del nodo nuevo ha cambiado de la del nodo padre, añadir la acción de nuevo para poder hacerla.
					if(!sameOrientation)
					{
						theRoad.add(actAction);
					}
					
					// Generar propiamente el nodo hijo con los datos anteriores.
					node newNode = new node(actPos, actOrientation, manhattanDist(actPos, destination), theRoad);
					
					isOnClosed = false;
					isOnOpen = false;
					
					// Chequear si el nodo ya se encuentra en la lista de CERRADOS.
					for(int j = 0; j < closed.size(); j++)
					{
						if(newNode.equals(closed.get(j)))
						{
							/*
							 * Si el nodo actual se encuentra en CERRADOS y tiene un costo menor que el costo
							 * actual añadirlo en ABIERTOS y quitarlo de CERRADOS.
							 */
							isOnClosed = true;
							if(newNode.getAccumCost() < closed.get(j).getAccumCost())
							{
								open.add(closed.get(j));
								closed.remove(closed.get(j));
							}
							break;
						}
					}
					
					// Chequear si el nodo se encuentra ya en ABIERTOS.
					if(!isOnClosed)
					{
						for(int j = 0; j < open.size(); j++)
						{
							if(newNode.equals(open.get(j)))
							{
								/*
								 * Si el nodo actual se encuentra en ABIERTOS y tiene un costo menor que su copia
								 * en ABIERTOS, reemplazarlo en ABIERTOS.
								 */
								if(newNode.getAccumCost() < open.get(j).getAccumCost())
								{
									open.get(j).update(newNode);
								}
								isOnOpen = true;
								
								break;
							}
						}
					}
					
					// Sino está ni en ABIERTOS ni CERRADOS, añadirlo a ABIERTOS.
					if(!isOnOpen && !isOnClosed)
					{
						open.add(newNode);
					}
				}
			}
			// Reordenar los nodos para obtener aquel con mejor costo.
			Collections.sort(open);
		}
		
		// Actualizar la orientación ya que si sigue otra ejecución de A* luego, debe tener la orientación actualizada.
		playerOrientation = actNode.getOrientation();
		
		// Devolver la ruta generada.
		return actNode.getActionList();
	}
	
	/**
	 * @brief Algoritmo TSP Cercanía Modificado para obtener el orden de las gemas. Recuerdos de Algorítmica ;-)
	 * @param gemList	Lista de Vector2D con las posiciones de las gemas
	 * @return	Lista de Vector2D con las gemas ordenadas
	 */
	public ArrayList<Vector2d> greedyTSP(ArrayList<Vector2d> gemList)
	{	
		ArrayList<Vector2d> gemRoad = new ArrayList<Vector2d>();
		
		int counter = 0, 
			bestNodeIndex = -1, 
			gemSize = Math.min(9, gemList.size());
		
		double minDist, actDist;
				
		// La "ciudad" inicial es la posición actual del Avatar.
		Vector2d actualNode = playerPos;

		// Realizar el algoritmo hasta la cantidad de gemas actual o 9 gemas, lo que sea menor.
		while(counter < gemSize)
		{
			// Inicializar distancia minima al valor tope.
			minDist = Double.MAX_VALUE;
			
			// Por cada "ciudad"/gema, evaluar cual posee la distancia mínima Manhattan de esta a otra "ciudad"/gema/avatar
			for(int i = 0; i < gemList.size(); i++)
			{
				actDist = manhattanDist(actualNode,gemList.get(i));
				if(actDist < minDist)
				{
					// Guardar la mejor.
					minDist = actDist;
					bestNodeIndex = i;
				}
			}
			
			// Actualizar la "ciudad"/gema
			actualNode = gemList.get(bestNodeIndex);
			// Retirar la gema de la lista
			gemRoad.add(gemList.get(bestNodeIndex));
			// Añadirla a la lista de gemas ordenada por cercanía
			gemList.remove(bestNodeIndex);
			
			counter++;
		}
		// Naturalmente, como no es realmente un TSP, no hay camino de regreso (Ni suma de costo).
		// Se retorna la lista de nodos ordenados.
		
		return gemRoad;
	}
	
	/**
	 * @brief Localizar las gemas y generar una ruta hacia ellas
	 * @param stateObs		Observaciones
	 * @param elapsedTimer	Temporizador
	 */
	public void gemLocator(StateObservation stateObs, ElapsedCpuTimer elapsedTimer)
	{
		// Limpiar el camino.
		road.clear();
		
		// Obtener las gemas actuales y meterlas en un vector.
		ArrayList<Observation>[] gemRawList = stateObs.getResourcesPositions(stateObs.getAvatarPosition());
		ArrayList<Vector2d> gemAuxList = new ArrayList<Vector2d>();
		
		// Actualizar el contador interno.
		if(stateObs.getAvatarResources().get(6) == null)
			internalGemCount = 0;
		else
			internalGemCount = stateObs.getAvatarResources().get(6) - 1;
		
				
		for(int i=0; i < gemRawList[0].size(); i++)
		{
			gemAuxList.add(new Vector2d(Math.floor(gemRawList[0].get(i).position.x / gridScale.x), 
								  Math.floor(gemRawList[0].get(i).position.y / gridScale.y)));
		}
		
		// Ordenar las gemas con una estrategia greedy basada en el TSP
		ArrayList<Vector2d>gemList = greedyTSP(gemAuxList);
		
		// Obtener la ruta de la posición actual hasta las gemas restantes por medio de A*.
		Vector2d actGem = gemList.get(0);
		gemList.remove(0);
				
		road = aStar(playerPos, actGem, stateObs, elapsedTimer);	
		
		while(!gemList.isEmpty())
		{
			road.addAll( aStar(actGem, gemList.get(0), stateObs, elapsedTimer));
			actGem = gemList.get(0);
			gemList.remove(0);
		}

	}
	
	/**
	 * @brief Calcular el "calor" en una casilla respecto a un enemigo.
	 * @param heatSrc	Vector 2D que indica la posición de un enemigo.
	 * @param position	Vector 2D que indica la posición a evaluar.
	 * @return Valor de calor en la posicion especificada respecto al enemigo.
	 */
	public double heat(Vector2d heatSrc, Vector2d position)
	{
		/*
		 * - Para obtener el calor, se realiza un cálculo de una función cóncava que decrementa no linealmente.
		 * - La función es  10 / ( (posicion.x - fuenteCalor.x)**2 + (posicion.y - fuenteCalor.y)**2 + 1 )
		 * 		- El valor máximo, cuando posicion = fuenteCalor es 10, y este valor decrementa rápidamente mientras
		 * 		  la posicion se aleja más de la fuente.
		 */
		return ( 10 / ( (Math.pow((position.x - heatSrc.x), 2)) + (Math.pow((position.y - heatSrc.y), 2)) + 1 ) );	
	}
	
	/**
	 * @brief Obtener el calor para la posición actual del Avatar
	 * @param stateObs	Observaciones
	 * @return Valor de calor para la posición del Avatar
	 */
	public double getDanger(StateObservation stateObs)
	{
		// Limpiar el mapa del tick anterior
		heatMap.clear();
		
		// Rellenar el mapa con las paredes, marcadas con un 100 de calor.
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
		
		// Obtener los enemigos y añadirlos a un vector.
		ArrayList<Observation>[] enemy = stateObs.getNPCPositions();
		ArrayList<Vector2d> enemyPos = new ArrayList<Vector2d>();
		
		for(int i=0; i < enemy[0].size(); i++)
		{
			enemyPos.add(new Vector2d(enemy[0].get(i).position.x / gridScale.x, enemy[0].get(i).position.y / gridScale.y));
		}
		
		int actX;
		int actY;
		
		// Por cada enemigo, generar un mapa de calor de 8 x 8 casillas a su alrededor.
		for(int i=0; i < enemyPos.size(); i++)
		{
			actX = (int)enemyPos.get(i).x;
			actY = (int)enemyPos.get(i).y;
						
			for(int j=actX-dangerRadius; j < actX+dangerRadius; j++)
			{
				// Evitar escribir fuera de los limites del mapa
				if(j >= 0 && j < worldMap.length)
				{
					
					for(int k=actY-dangerRadius; k < actY+dangerRadius; k++)
					{
						// Idem.
						if(k >= 0 && k < worldMap[0].length) 
						{
							// Obtener el calor para la posición especificada, el calor se acumula.
							heatMap.get(j).set(k, heatMap.get(j).get(k) + heat(enemyPos.get(i), new Vector2d(j, k)));
						}
					}
				}
			}
			
		}
		
		// Retornar el calor en la posición actual del Avatar.
		return heatMap.get((int)playerPos.x).get((int)playerPos.y);
	}
	
	/**
	 * @brief Saber si la orientación del Avatar actual concuerda con la orientación especificada.
	 * @param x		Componente horizontal, (1,0) = Derecha, (-1,0) = Izquierda.
	 * @param y		Componente vertical, (0,1) = Abajo, (0,-1) = Arriba 
	 * @return Verdadero si coincide, Falso de lo contrario.
	 */
	public Boolean isSameOrientation(int x, int y)
	{
		return ((int)playerOrientation.x == x && (int)playerOrientation.y == y); 
	}
	
	/**
	 * @brief Devolver una acción evasiva respecto a un enemigo.
	 * @param stateObs	Observaciones
	 * @return Acción evasiva
	 */
	public Types.ACTIONS evade(StateObservation stateObs)
	{
		ACTIONS react = ACTIONS.ACTION_NIL;
		double bestSoFar = 100;
		
		/**
		 * Seleccionar cual de los cuatro movimientos posibles reduce más el peligro e irse hacia él.
		 */
		
		if(heatMap.get(((int)playerPos.x)).get((int)playerPos.y - 1) < bestSoFar)
		{
			react = ACTIONS.ACTION_UP;
			bestSoFar = heatMap.get(((int)playerPos.x)).get((int)playerPos.y - 1);
		}
		
		if(heatMap.get(((int)playerPos.x)).get((int)playerPos.y + 1) < bestSoFar)
		{
			react = ACTIONS.ACTION_DOWN;
			bestSoFar = heatMap.get(((int)playerPos.x)).get((int)playerPos.y + 1);

		}
		
		if(heatMap.get(((int)playerPos.x - 1)).get((int)playerPos.y) < bestSoFar)
		{
			react = ACTIONS.ACTION_LEFT;
			bestSoFar = heatMap.get(((int)playerPos.x - 1)).get((int)playerPos.y);

		}
		
		if(heatMap.get(((int)playerPos.x) + 1).get((int)playerPos.y) < bestSoFar)
		{
			react = ACTIONS.ACTION_RIGHT;
			bestSoFar = heatMap.get(((int)playerPos.x + 1)).get((int)playerPos.y);
		}
			
		return react;
	}
	
	/**
	 * @brief Devuelve la acción a realizar por el agente.
	 * @param stateObs		Observaciones
	 * @param elapsedTimer	Temporizador
	 * @return Acción que el agente va a realizar.
	 */
	public Types.ACTIONS act(StateObservation stateObs, ElapsedCpuTimer elapsedTimer)
	{
		// Acción por defecto.
		actAction = ACTIONS.ACTION_NIL;
		
		// Obtener la posición y orientación actualizada.
		playerPos.x = stateObs.getAvatarPosition().x / gridScale.x;
		playerPos.y = stateObs.getAvatarPosition().y / gridScale.y;	
		playerOrientation = stateObs.getAvatarOrientation();

		// Si hay enemigos en el mapa, generar mapa de calor.
		if(hasEnemies)
		{
			actDanger = getDanger(stateObs);
		}	
		
		// Si el peligro de la posición actual es superior a 0, utilizar estrategia reactiva.
		if(actDanger > 0)
		{
			// Tomar acciones evasivas.
			actAction = evade(stateObs);
			// Se deben recalcular las rutas.
			hasRouteToGem = false;
			hasRouteToPortal = false;
		}
		// Sino, continuar con estrategia deliberativa.
		else
		{
			// Si aun faltan recoger 9 gemas y si el mapa posee gemas entrar.
			if((stateObs.getAvatarResources().get(6) == null || stateObs.getAvatarResources().get(6) < 9) && hasGems)
			{

				// Si no tengo ruta, generarla.
				if(!hasRouteToGem)
				{
					gemLocator(stateObs, elapsedTimer);
				}
				
				//	Con la ruta, seguirla tick a tick.
				if(road.size() > 0)
				{
					actAction = road.get(0);
					road.remove(0);
				}

			}
			else
			{
				/*
				 * Generar una ruta si:
				 * 	- El mapa no tiene ni gemas ni enemigos. (Nivel Deliberativo Simple)
				 * 	- El mapa posee gemas (Aunque ya estén recogidas las 9) (Nivel Deliberativo Compuesto)
				 * 	- El mapa tiene gemas y enemigos. (Nivel Reactivo-Deliberativo)
				 * 
				 * 	No se genera una ruta si el mapa tiene solamente enemigos. (Niveles Reactivo Simple y Compuesto)
				 */
				if(hasGems || !hasGems && !hasEnemies || hasGems && hasEnemies)
				{

					// Si no tengo ruta completa hacia el portal, generarla.
					if(!hasRouteToPortal)
					{
						road = aStar(playerPos, portalPos, stateObs, elapsedTimer);
					}
					
					//	Con la ruta, seguirla tick a tick.
					if(road.size() > 0)
					{
						actAction = road.get(0);
						road.remove(0);
					}
				}

			}
		}
		return actAction;	
	}
}