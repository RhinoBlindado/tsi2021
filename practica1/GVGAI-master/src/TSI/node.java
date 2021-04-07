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

package TSI;

import tools.Vector2d;
import java.util.ArrayList;
import ontology.Types.ACTIONS;

public class node implements Comparable<node>{
	private Vector2d nodePos;
	private Vector2d nodeOrientation;
	
	private double totalCost;
	private double accumCost;
	private double expectedCost;
	
	private ArrayList<ACTIONS> routeSoFar = new ArrayList<ACTIONS>();
	
	
	public node(Vector2d position, Vector2d orientation, double fowardCost, ArrayList<ACTIONS> route)
	{
		this.nodePos = position;
		this.nodeOrientation = orientation;
		this.accumCost = route.size();
		this.routeSoFar = new ArrayList<ACTIONS>(route);
		this.expectedCost = fowardCost;
		this.totalCost = this.accumCost + this.expectedCost;
	}
	 
	
	@Override
	public String toString()
	{
		return "node: "+"["+"Pos["+ this.nodePos.x+"]["+ this.nodePos.y+"], Orr["+ this.nodeOrientation.x+"]["+ 
				this.nodeOrientation.y+"] f(n)="+ this.totalCost+" = acc ["+ this.accumCost+"] + exp ["+ this.expectedCost+"]]";
	}
	
	public Vector2d getPos()
	{
		return this.nodePos;
	}

	public Vector2d getOrientation()
	{
		return this.nodeOrientation;
	}
	
	public ArrayList<ACTIONS> getActionList()
	{
		return this.routeSoFar;
	}
	
	public double getAccumCost()
	{
		return this.accumCost;
	}
	
	public void update(node arg0)
	{
		this.nodeOrientation = arg0.nodeOrientation;
		this.accumCost = arg0.accumCost;
		this.routeSoFar = new ArrayList<ACTIONS>(arg0.routeSoFar);
		this.expectedCost = arg0.expectedCost;
		this.totalCost = arg0.totalCost;
	}
	
	public int compareTo(node arg0) 
	{
		int value = 0;
		
		if(this.totalCost > arg0.totalCost)
			value = 1;
		
		if(this.totalCost < arg0.totalCost)
			value = -1;
		
		if(this.totalCost == arg0.totalCost)
		{
			if(this.accumCost > arg0.accumCost)
			{
				value = 1;
			}
			
			if(this.accumCost < arg0.accumCost)
			{
				value = -1;
			}
		}
		
		return value;
	}
}
