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
	
	private Vector2d portalPos;
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
	
	public 
	
	@Override
	public String toString()
	{
		return "node: "+"["+"Pos X: "+ this.nodePos.x+", Pox Y: "+ this.nodePos.y+", Orr X: "+ this.nodeOrientation.x+", Orr Y: "+ this.nodeOrientation.y+", f(n): "+ this.totalCost+" = g(n): "+ this.accumCost+" + h(n): "+ this.expectedCost+"]\n";
	}
	
	public Vector2d getPos()
	{
		return this.nodePos;
	}

	public Vector2d getOrientation()
	{
		return this.nodeOrientation;
	}
	
	
	@Override
	public int compareTo(node arg0) 
	{
		int value = 0;
		if(this.totalCost == arg0.totalCost)
		{
			if(this.expectedCost > arg0.expectedCost)
			{
				value = -1;
			}
			else
			{
				value = 1;
			}
			
		}
		else
		{
			if(this.totalCost > arg0.totalCost)
			{
				value = -1;	
			}
			else 
			{
				value = 1;
			}
		}
		return value;
	}
}
