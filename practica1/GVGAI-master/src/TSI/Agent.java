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

// Package Info 
package TSI;

// Packages Used
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;

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
	ArrayList<ACTIONS> road;
	
	public Agent(StateObservation stateObs, ElapsedCpuTimer elapsedTimer)
	{
		gridScale = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length , 
        		stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);  
        
		// Get the player position, orientation & possible actions.
		playerPos = stateObs.getAvatarPosition();
		playerPos.x = Math.floor(playerPos.x / gridScale.x);
		playerPos.y = Math.floor(playerPos.y / gridScale.y);
		
		playerOrientation = stateObs.getAvatarOrientation();
		
		playerActions = stateObs.getAvailableActions();
		sizePlayerActions = playerActions.size();
		
		// Get the portal information
        ArrayList<Observation>[] portalList = stateObs.getPortalsPositions(stateObs.getAvatarPosition());
        portalPos = portalList[0].get(0).position;
        portalPos.x = Math.floor(portalPos.x / gridScale.x);
        portalPos.y = Math.floor(portalPos.y / gridScale.y);
		
		// Prepare the data for A*
		node root = new node(playerPos, playerOrientation, expectedCost(playerPos, portalPos), new ArrayList<ACTIONS>());
		open.add(root);
		
		
		//map = stateObs.getObservationGrid();
		//Vector2d pos = stateObs.getAvatarPosition();
	//	aStar(portalPos, stateObs, elapsedTimer);
		

	}
	
	public double expectedCost(Vector2d origin, Vector2d destination)
	{
		return Math.abs(origin.x - destination.x) + Math.abs(origin.y - destination.y);
	}
	
	public void aStar(Vector2d destination, StateObservation stateObs, ElapsedCpuTimer elapsedTimer)
	{
		Vector2d actPos;
		Vector2d actOrientation;
		ACTIONS actAction;
		node actNode;
		ArrayLisr
		
		while(true)
		{
			actNode = open.get(0);

			// If node is on objective, stop.
			if( (actNode.getPos().x == destination.x) && (actNode.getPos().y == destination.y) )
			{
				break;
			}
			
			open.remove(0);
			closed.add(actNode);
			
			// Expand Current Node: Move to another tile in the map.
			//  - Loop starts at 1 because the 0th action is ACTION_USE.
			for(int i = 1; i < sizePlayerActions; i++)
			{
				actPos = actNode.getPos();
				actOrientation = actNode.getOrientation();
				actAction = playerActions.get(i);
				
				if(actAction == ACTIONS.ACTION_UP)
				{
					actPos.x += 1;
				}
				
				if(actAction == ACTIONS.ACTION_DOWN)
				{
					actPos.x += -1;
				}
				
				if(actAction == ACTIONS.ACTION_RIGHT)
				{
					actPos.y += 1;
				}

				if(actAction == ACTIONS.ACTION_LEFT)
				{
					actPos.y += -1;
				}

			}
		}
	}
	
	public Types.ACTIONS act(StateObservation stateObs, ElapsedCpuTimer elapsedTimer)
	{
		return Types.ACTIONS.ACTION_NIL;	
	}
}