
// TODO Es muy raro esta clase tan importante para el dominio que casi no tiene métodos, sólo atributos.
// Resulta evidente que hay responsabilidades mal asignadas.
class Estudiante{
	var property notasMaterias
	var property carreras
	var property materiasAprobadas
	var property creditosAcumulados
	var property materiasInscripto
	var property materiasEnListaEspera
	
	method aprobo(materiaAprobada){
		materiasAprobadas.add(materiaAprobada.materia() )
		creditosAcumulados += materiaAprobada.materia().creditos()
	}
}

class Materia {
	var property carrera
	var property inscriptos
	var property anio
	var property cupo
	var property creditos
	var property listaDeEspera

	method hayCupo(){
		return inscriptos.size() < cupo
	}
	
	method inscribir(estudiante){
		inscriptos.add(estudiante)
		estudiante.materiasInscripto().add(self)
	}
	
	method agregarAListaDeEspera(estudiante){
		listaDeEspera.add(estudiante)
		estudiante.materiasEnListaEspera().add(self)
	}
	
	method cumpleRequisitos(estudiante){
		return  estudiante.carreras().contains(carrera) 
				and	not self.inscriptos().contains(estudiante)
				and	not estudiante.materiasAprobadas().contains(self)
	}
}

class MateriaConCorrelativas inherits Materia{
	var property correlativas
	
	method cumpleCorrelativas(estudiante){
		// TODO Esto es una hackeada, evitalo.
		return estudiante.materiasAprobadas().filter
			{ materia=> correlativas.contains(materia) } == correlativas
	}
	override method cumpleRequisitos(estudiante){
		return super(estudiante) and self.cumpleCorrelativas(estudiante)
	}
}

class MateriaConCreditos inherits Materia{
	var creditosNecesarios
	
	method tieneLosCreditosNecesarios(estudiante){
		return estudiante.creditosAcumulados() >= creditosNecesarios
	}
	
	override method cumpleRequisitos(estudiante){
		return super(estudiante) and self.tieneLosCreditosNecesarios(estudiante)
	}
}

class MateriaPorAnio inherits Materia {
	
	
	method carreraDe(estudiante){
		return estudiante.carreras().find{ _carrera=> _carrera == carrera }
	}
	
	method cumpleConMateriasDe(estudiante){
		// TODO Hackeada y repite código con MateriaConCorrelativas 
		return self.carreraDe(estudiante).materiasDe(anio - 1).asSet() 
			   == estudiante.materiasAprobadas().filter{ materia=> materia.anio() == anio - 1 
			   		and materia.carrera() == carrera
			   			}.asSet()
	}
	
	override method cumpleRequisitos(estudiante){
		// TODO Este método y otros similares son innecesarios
		return super(estudiante) and self.cumpleConMateriasDe(estudiante)
	}
}

class MateriaAprobada{
	var property materia
	var property nota
}

class Carrera{
	var property materias
	
	method materiasDe(anio){
		return materias.filter{ materia=> materia.anio() == anio }
	}
}

// TODO Esta clase es innecesaria, algunos de sus métodos corresponden 
// mejor a otros objetos y otros directamente se pueden eliminar.
class  Universidad{

	method puedeCursar(estudiante,materia){
		return materia.cumpleRequisitos(estudiante)
	}
	
	method registrarMateriaAprobada(estudiante,materiaAprobada){
		if(not estudiante.materiasAprobadas().contains(materiaAprobada.materia())){
			 estudiante.aprobo(materiaAprobada) 
		}
		else {
			 self.error("no se puede anotar 2 veces la nota")
		}
	}
	
	method estudiantePuedeInscribirse(estudiante,materia){
		return self.puedeCursar(estudiante,materia) and materia.hayCupo()
	}
	
	method inscribirEstudiante(estudiante, materia){
		if( self.estudiantePuedeInscribirse(estudiante,materia) ){
			materia.inscribir(estudiante)
		}
		// TODO Valida dos veces si puede cursar.
		else if( self.puedeCursar(estudiante,materia) ){
			materia.agregarAListaDeEspera(estudiante)	
		}
	}
	
	method darDeBaja(estudiante,materia){
		// TODO Falta delegación
		// TODO No está notificando al estudiante del cambio
		materia.inscriptos().remove(estudiante)
		if( materia.listaDeEspera().size() > 0 ){
			materia.inscriptos().add(materia.listaDeEspera().get(1))
		}
	}

	method estudiantesInscriptos(materia){
		return materia.inscriptos()
	}
	method estudiantesEnListaDeEspera(materia){
		return materia.listaDeEspera()
	}

	// TODO Esto no tiene sentido, devuelve la misma carrera que le pasás por parámetro	
	method carreraDelEstudiante(estudiante,carrera){
		return estudiante.carreras().find{_carrera => _carrera == carrera}
		
		}
	method materiasQueSePuedeInscribir(estudiante,carrera){
			return self.carreraDelEstudiante(estudiante,carrera).materias().filter{
				materia=> self.puedeCursar(estudiante, materia)
			}
	}
	method materiasQueEstaInscripto(estudiante){
		return estudiante.materiasInscripto()
	}
	
	method materiasEnListaDeEspera(estudiante){
		return estudiante.materiasEnlistaEspera()
	}
}


