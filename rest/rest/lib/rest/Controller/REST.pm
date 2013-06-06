package rest::Controller::REST;
use Moose;
use namespace::autoclean;
use Covetel::LDAP;
use Covetel::LDAP::Person;
use Data::Dumper;

BEGIN {extends 'Catalyst::Controller::REST'; }
use Params::Validate qw(SCALAR OBJECT);

=head1 NAME

rest::Controller::REST - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

has ldap =>(
            is => "rw",	
            isa => 'Covetel::LDAP',
            builder => "_build_ldap"
            );

sub _build_ldap {

	my $self = shift;
	my $ldap = Covetel::LDAP->new();
	return $ldap;
}

sub utf8_decode {
	my ($self, $cadena) = @_;
	utf8::decode($cadena);
	return $cadena;
}

sub status_server_error {
	my $self = shift;
	my $c = shift;
	my %p = Params::Validate(@_,  {message => {type =>SCALAR}, }, );
    $c->response->status(500);
    $c->log->debug( "Status Internal Server Error:  ". p{'message'}) if $c->debug;
    $self->_set_entity($c,  {error=> p{'message'}});
    return 1;
}
sub prueba :Local :ActionClass('REST') {

}

sub prueba_GET {

	my ($self, $c) = @_;

	#$self->status_ok($c,
	#		 entity => {
	#			nombre => 'Jennifer',
	##			apellido => 'Maldonado'
	#		 }
	#		);
	$self->status_ok( $c , entity => { radiohead => " Is a good band ! " } ) ;

}

sub prueba_POST {
	my ($self, $c) = @_;
	$self -> status_created($c ,
				location => $c->req->uri->as_string ,
				entity => {
					radiohead => " Is a good band ! " ,
					}
				);

}

sub estado :Local :ActionClass('REST'){

}

sub estado_GET {

	my ($self, $c) = @_;
	$self-> status_gone ( $c,
			message => " El documento fue eliminado . " ,);
	

}

sub estado_POST {

	my ($self, $c) = @_;
	$self->status_not_found($c , message => "No puede encontrar lo que estas buscando" ,);

}

sub estado_PUT {

	my ($self, $c) = @_;
	$self->status_bad_request(
				$c,
				message => 'No puedo darle lo que me pide'
				);

}
sub persona :Local :ActionClass('REST') { }

sub persona_GET {

	my ($self, $c,  $uid) = @_;
    my $person;
    if ($uid) {
        my $ldap = Covetel::LDAP->new; 
        $person = $ldap->person({uid=> $uid});
    }
    if ($person){
    $self->status_ok( $c,  
                    entity => {
                        uid => $person->uid, 
                        nombre => $person->firstname, 
                        apellido => $person->lastname, 
                        cedula => $person->ced, 
                    } 
                  );
    }
    else { $self->status_not_found($c, 
                                message => 'Persona no encontrada',  
                            ); 
    }
}

sub persona_POST {

    my ($self, $c) = @_;
    my $data = $c->req->data;
    $c->log->debug(Dumper($data));
    my $person;
    $person = Covetel::LDAP::Person->new($data);
    $c->log->debug(Dumper($person));
    #$person = Covetel::LDAP::Person->new({uid=> 'jennni',
    #                                       firstname=>'jennifer',
    #                                       lastname=>'Oto apellido',
    #                                       ced => '1234567',
    #                                       email=>'jjjj@mmmm.com'  });
    my $dn = $person->dn(); 
    $c->log->debug($person->add);
    if ($person->add){
                $self->status_created( $c,  
                    location => $c->req->uri->as_string,  
                    entity => {
                        uid => $person->uid, 
                        nombre => $person->uid, 
                        apellido => $person->uid, 
                        cedula => $person->uid, 
                    } 
                  );
    }
    else {
        $self->status_not_found($c, 
                                message => 'Persona no creada',  
                            ); 
    }
}

sub persona_PUT {

	my ($self, $c) = @_;
    my $data = $c->request->data;
    my $ldap= $self->ldap;
    my $person = $ldap->person({uid => $data->{uid} });
    if ($person) {
        foreach (keys %{$data}){
            $person->$_($data->{$_});
        }
    }
    else {
        $self->status_not_found($c,  message =>"Persona no encontrada");
    }
    if ($person->update){
        $self->status_no_content($c); 
    }
    else {
        # acÃ¡ va el status personalizado 
        $self->status_server_error($c);
    }
}

sub persona_DEL {

	my ($self, $c) = @_;
}
sub personas :Local :ActionClass('REST') {

}

sub personas_GET {

	my ($self, $c) = @_;
    my @lista = $self->ldap->person();
    @lista = (@lista,  @lista, @lista);
    my %datos;
    $datos{aaData} = [
        map {
            [
                $self->utf8_decode($_->firstname), 
                $self->utf8_decode($_->lastname), 
                $_->ced, 
                $_->email, 
                $_->uidNumber, 
                $_->uid, 
            ]
        } grep {!($_->uid eq 'root')} @lista,  
    ];
    $self->status_ok($c,  entity=>\%datos);

}

sub personas_POST {

	my ($self, $c) = @_;
}

sub personas_PUT {

	my ($self, $c) = @_;
}

sub personas_DEL {

	my ($self, $c) = @_;
}
=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched rest::Controller::REST in REST.');
}


=head1 AUTHOR

Jenni,5555555,4444444,333333

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
