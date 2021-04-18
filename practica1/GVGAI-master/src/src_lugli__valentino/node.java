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

package src_lugli__valentino;

import tools.Vector2d;
import java.util.ArrayList;
import ontology.Types.ACTIONS;

/**
 * Clase auxiliar para el tipo de dato "Nodo" utilizado para el A*
 */
public class node implements Comparable<node>
{
	/*
	 * -nodePos indica las coordenadas del nodo
	 * -nodeOrientation indica la orientación del nodo
	 */
	private Vector2d nodePos;
	private Vector2d nodeOrientation;
	
	/*
	 * totalCost almacena el costo total del camino.
	 * accumCost almacena el costo de llegar al nodo.
	 * expectedCost almacena el costo esperado para llegar al destino. 
	 */
	private double totalCost;
	private double accumCost;
	private double expectedCost;
	
	// routeSoFar almacena los pasos que requiere seguir el Avatar para llegar al nodo.
	private ArrayList<ACTIONS> routeSoFar = new ArrayList<ACTIONS>();
	
	
	/**
	 * @brief Constructor de la clase nodo
	 * @param position		Vector2D de la posicion en el mapa.
	 * @param orientation	Vector2D de la orientacion del nodo en el mapa.
	 * @param fowardCost	Calculo de la heuristica del costo esperado.
	 * @param route			Lista de acciones que el avatar debe hacer para llegar hasta el nodo.
	 */
	public node(Vector2d position, Vector2d orientation, double fowardCost, ArrayList<ACTIONS> route)
	{
		this.nodePos = position;
		this.nodeOrientation = orientation;
		
		// El coste acumulado se puede entender como los pasos que se han tomado hasta llegar al nodo.
		this.accumCost = route.size();
		
		// Se almacena la ruta, de esta manera mientras el A* avanza, se va guardando el camino al mismo tiempo.
		this.routeSoFar = new ArrayList<ACTIONS>(route);
		this.expectedCost = fowardCost;
		this.totalCost = this.accumCost + this.expectedCost;
	}
	 
	/**
	 * @brief Clase de depuración para ver que contenidos posee el nodo.
	 */
	@Override
	public String toString()
	{
		return "NODE: "+"["+"Pos["+ this.nodePos.x+"]["+ this.nodePos.y+"], Orr["+ this.nodeOrientation.x+"]["+ 
				this.nodeOrientation.y+"] f(n)="+ this.totalCost+" = acc ["+ this.accumCost+"] + exp ["+ this.expectedCost+"]]";
	}
	
	/**
	 * @brief Operador de igualdad del nodo.
	 * @param arg0	Nodo con el cual comparar
	 * @return	Booleano que indica si ambos nodos son iguales o no.
	 */
	public boolean equals(node arg0) 
	{
		return (this.getPos().equals(arg0.getPos()) && this.getOrientation().equals(arg0.getOrientation()));
    }
	
	/**
	 * @brief Obtener la posición del nodo.
	 * @return	Vector2D con la posición.
	 */
	public Vector2d getPos()
	{
		return this.nodePos;
	}

	/**
	 * @brief Obtener la orientación del nodo.
	 * @return	Vector2D con la orientación.
	 */
	public Vector2d getOrientation()
	{
		return this.nodeOrientation;
	}
	
	/**
	 * @brief Obtener la lista de acciones que posee el nodo.
	 * @return ArrayList de acciones.
	 */
	public ArrayList<ACTIONS> getActionList()
	{
		return this.routeSoFar;
	}
	
	/**
	 * @brief Obtener el costo acumulado del nodo.
	 * @return Valor del costo acumulado.
	 */
	public double getAccumCost()
	{
		return this.accumCost;
	}
	
	/**
	 * @brief Actualizar la información de un nodo.
	 * @param arg0 Nodo con el cual actualizar la información.
	 */
	public void update(node arg0)
	{
		this.nodeOrientation = arg0.nodeOrientation;
		this.accumCost = arg0.accumCost;
		this.routeSoFar = new ArrayList<ACTIONS>(arg0.routeSoFar);
		this.expectedCost = arg0.expectedCost;
		this.totalCost = arg0.totalCost;
	}
	
	/**
	 * @brief Operador de comparación de nodos.
	 * @param arg0	Nodo con el cual comparar.
	 * @return Entero indicando el valor de la comparación, un valor negativo da mas prioridad al nodo actual.
	 */
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
				value = 1;
			
			if(this.accumCost < arg0.accumCost)
				value = -1;
		}
		
		return value;
	}
}
