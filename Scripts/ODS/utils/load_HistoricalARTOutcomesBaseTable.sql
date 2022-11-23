u s e   t m p _ a n d _ a d h o c ;  
  
 - -   f i r s t   y o u   n e e d   t o   c r e a t e   t h e   t a b l e   t h a t   e v e r y t h i n g   w i l l   g o   i n t o  
 - - t r u n c a t e   t a b l e   A g g _ A R T O u t c o m e s  
 - -   s e l e c t   *   f r o m   A g g _ A R T O u t c o m e s  
  
 d e c l a r e    
 @ s t a r t _ d a t e   d a t e   =   < > ,  
 @ e n d _ d a t e   d a t e   =   < > ;  
 - -   d e c l a r e   y o u r   s t a r t   a n d   e n d   d a t e s .  
  
  
  
 - - - c r e a t i n g   a   t e m p o r a r y   t a b l e   w i t h   e n d   o f   d a y   d a t e s   f o r   e a c h   m o n t h   b e t w e e n   s t a r t   a n d   e n d  
 w i t h   d a t e s   a s   (  
             s e l e c t   d a t e f r o m p a r t s ( y e a r ( @ s t a r t _ d a t e ) ,   m o n t h ( @ s t a r t _ d a t e ) ,   1 )   a s   d t e  
             u n i o n   a l l  
             s e l e c t   d a t e a d d ( m o n t h ,   1 ,   d t e )  
             f r o m   d a t e s  
             w h e r e   d a t e a d d ( m o n t h ,   1 ,   d t e )   < =   @ e n d _ d a t e  
 )  
 s e l e c t    
 	 e o m o n t h ( d t e )   a s   e n d _ d a t e  
 i n t o   # m o n t h s  
 f r o m   d a t e s  
 o p t i o n   ( m a x r e c u r s i o n   0 ) ;  
  
  
  
  
 - - d e c l a r e   a s   o f   d a t e  
 d e c l a r e   @ a s _ o f _ d a t e   a s   d a t e ;  
  
 - - d e c l a r e   c u r s o r  
 d e c l a r e   c u r s o r _ A s O f D a t e s   c u r s o r   f o r  
 s e l e c t   *   f r o m   # m o n t h s  
  
 o p e n   c u r s o r _ A s O f D a t e s  
  
 f e t c h   n e x t   f r o m   c u r s o r _ A s O f D a t e s   i n t o   @ a s _ o f _ d a t e  
 w h i l e   @ @ F E T C H _ S T A T U S   =   0  
  
 b e g i n  
  
 w i t h   c l i n i c a l _ v i s i t s _ a s _ o f _ d a t e   a s   (  
         / *   g e t   v i s i t s   a s   o f   d a t e   * /  
         s e l e c t    
                 P a t i e n t P K ,  
                 P a t i e n t I D ,  
                 S i t e C o d e ,  
                 V i s i t D a t e ,  
                 N e x t A p p o i n t m e n t D a t e ,  
                 P o p u l a t i o n T y p e ,  
                 K e y P o p u l a t i o n T y p e ,  
                 C u r r e n t R e g i m e n ,  
                 E m r  
         f r o m     O D S . d b o . C T _ P a t i n e t  
         w h e r e   S i t e C o d e   >   0   a n d   V i s i t D a t e   < =   @ a s _ o f _ d a t e  
 ) ,  
 p h a r m a c y _ v i s i t s _ a s _ o f _ d a t e   a s   (  
           / *   g e t   p h a r m a c y   d i s p e n s a t i o n s   a s   o f   d a t e   * /  
         s e l e c t    
                 P a t i e n t P K ,  
                 P a t i e n t I D ,  
                 S i t e C o d e ,  
                 D i s p e n s e D a t e ,  
                 E x p e c t e d R e t u r n ,  
                 E m r  
         f r o m   O D S . d b o . C T _ P a t i e n t P h a r m a c y  
         w h e r e   S i t e C o d e   >   0   a n d   D i s p e n s e D a t e   < =   @ a s _ o f _ d a t e      
 ) ,  
 p a t i e n t _ a r t _ a n d _ e n r o l l m e n t _ i n f o   a s   (  
           / *   g e t   p a t i e n t s '   A R T   s t a r t   d a t e   * /  
         s e l e c t  
                 d i s t i n c t   A R T P a t i e n t s . P a t i e n t I D ,  
                 A R T P a t i e n t s . P a t i e n t P K ,  
                 A R T P a t i e n t s . S i t e C o d e ,  
                 A R T P a t i e n t s . S t a r t A R T D a t e ,  
                 A R T P a t i e n t s . S t a r t R e g i m e n ,  
                 A R T P a t i e n t s . S t a r t R e g i m e n L i n e ,  
                 P a t i e n t s . R e g i s t r a t i o n A t C C C   a s   E n r o l l m e n t D a t e ,  
                 P a t i e n t s . D O B ,  
                 P a t i e n t s . G e n d e r ,  
                 P a t i e n t s . D a t e C o n f i r m e d H I V P o s i t i v e ,  
                 d a t e d i f f ( y y ,   P a t i e n t s . D O B ,   P a t i e n t s . R e g i s t r a t i o n A t C C C )   a s   A g e E n r o l l m e n t  
         f r o m   O D S . d b o . C T _ A R T P a t i e n t s   a s   A R T P a t i e n t s  
         l e f t   j o i n   O D S . d b o . C T _ P a t i e n t   a s   P a t i e n t s     o n   P a t i e n t s . P a t i e n t I D   =   A R T P a t i e n t s . P a t i e n t I D  
         a n d   P a t i e n t s . P a t i e n t P K   =   A R T P a t i e n t s . P a t i e n t P K  
         a n d   P a t i e n t s . S i t e C o d e   =   A R T P a t i e n t s . S i t e C o d e  
 ) ,  
 v i s i t _ e n c o u n t e r _ a s _ o f _ d a t e _ o r d e r i n g   a s   (  
           / *   o r d e r   v i s i t s   a s   o f   d a t e   b y   t h e   V i s i t D a t e   * /  
         s e l e c t    
                 c l i n i c a l _ v i s i t s _ a s _ o f _ d a t e . * ,  
                 r o w _ n u m b e r ( )   o v e r   ( p a r t i t i o n   b y   P a t i e n t P K ,   P a t i e n t I D ,   S i t e C o d e   o r d e r   b y   V i s i t D a t e   d e s c )   a s   r a n k  
         f r o m   c l i n i c a l _ v i s i t s _ a s _ o f _ d a t e  
 ) ,  
 p h a r m a c y _ d i s p e n s e _ a s _ o f _ d a t e _ o r d e r i n g   a s   (  
         / *   o r d e r   p h a r m a c y   d i s p e n s a t i o n s   a s   o f   d a t e   b y   t h e   V i s i t D a t e   * /  
         s e l e c t    
                 p h a r m a c y _ v i s i t s _ a s _ o f _ d a t e . * ,  
                 r o w _ n u m b e r ( )   o v e r   ( p a r t i t i o n   b y   P a t i e n t P K ,   P a t i e n t I D ,   S i t e C o d e   o r d e r   b y   D i s p e n s e D a t e   d e s c )   a s   r a n k  
         f r o m   p h a r m a c y _ v i s i t s _ a s _ o f _ d a t e  
 ) ,  
 l a s t _ v i s i t _ e n c o u n t e r _ a s _ o f _ d a t e   a s   (  
         / * g e t   t h e   l a t e s t   v i s i t   r e c o r d   f o r   p a t i e n t s   f o r   a s   o f   d a t e   * /  
         s e l e c t    
                 *  
         f r o m   v i s i t _ e n c o u n t e r _ a s _ o f _ d a t e _ o r d e r i n g  
         w h e r e   r a n k   =   1  
 ) ,  
 l a s t _ p h a r m a c y _ d i s p e n s e _ a s _ o f _ d a t e   a s   (  
         / * g e t   t h e   l a t e s t   p h a r m a c y   d i s p e n s a t i o n s   r e c o r d   f o r   p a t i e n t s   f o r   a s   o f   d a t e   * /  
         s e l e c t  
                 *  
         f r o m   p h a r m a c y _ d i s p e n s e _ a s _ o f _ d a t e _ o r d e r i n g  
         w h e r e   r a n k   =   1  
 ) ,  
 e f f e c t i v e _ d i s c o n t i n u a t i o n _ o r d e r i n g   a s   (  
         / * o r d e r   t h e   e f f e c t i v e   d i s c o n t i n u a t i o n   b y   t h e   E f f e c t i v e D i s c o n t i n u a t i o n D a t e * /  
         s e l e c t    
                 P a t i e n t I D ,  
                 P a t i e n t P K ,  
                 S i t e C o d e ,  
                 E f f e c t i v e D i s c o n t i n u a t i o n D a t e ,  
                 E x i t D a t e ,  
                 E x i t R e a s o n ,  
                 r o w _ n u m b e r ( )   o v e r   ( p a r t i t i o n   b y   P a t i e n t P K ,   P a t i e n t I D ,   S i t e C o d e   o r d e r   b y   E f f e c t i v e D i s c o n t i n u a t i o n D a t e   d e s c )   a s   r a n k  
         f r o m   O D S . d b o . C T _ P a t i e n t S t a t u s  
         w h e r e   E x i t D a t e   i s   n o t   n u l l   a n d   E f f e c t i v e D i s c o n t i n u a t i o n D a t e   i s   n o t   n u l l  
 ) ,  
 l a t e s t _ e f f e c t i v e _ d i s c o n t i n u a t i o n   a s   (  
         / * g e t   t h e   l a t e s t   d i s c o n t i n u a t i o n   r e c o r d * /  
         s e l e c t    
                 *  
         f r o m   e f f e c t i v e _ d i s c o n t i n u a t i o n _ o r d e r i n g  
         w h e r e   r a n k   =   1  
 ) ,  
 e x i t s _ a s _ o f _ d a t e   a s   (  
         / *   g e t   e x i t s   a s   o f   d a t e   * /  
         s e l e c t    
                 P a t i e n t I D ,  
                 P a t i e n t P K ,  
                 S i t e C o d e ,  
                 E x i t D a t e ,  
                 E x i t R e a s o n  
         f r o m   O D S . d b o . C T _ P a t i e n t S t a t u s  
         w h e r e   E x i t D a t e   < =   @ a s _ o f _ d a t e    
 ) ,  
 e x i t s _ a s _ o f _ d a t e _ o r d e r i n g   a s   (  
         / *   o r d e r   t h e   e x i t s   b y   t h e   E x i t D a t e * /  
         s e l e c t    
                 P a t i e n t I D ,  
                 P a t i e n t P K ,  
                 S i t e C o d e ,  
                 E x i t D a t e ,  
                 E x i t R e a s o n ,  
                 r o w _ n u m b e r ( )   o v e r   ( p a r t i t i o n   b y   P a t i e n t P K ,   P a t i e n t I D ,   S i t e C o d e   o r d e r   b y   E x i t D a t e   d e s c )   a s   r a n k  
         f r o m   e x i t s _ a s _ o f _ d a t e  
 ) ,  
 l a s t _ e x i t _ a s _ o f _ d a t e   a s   (  
         / *   g e t   l a t e s t   e x i t _ d a t e   a s   o f   d a t e   * /  
         s e l e c t    
                 *  
         f r o m   e x i t s _ a s _ o f _ d a t e _ o r d e r i n g  
         w h e r e   r a n k   =   1  
 ) ,  
 v i s i t s _ a n d _ d i s p e n s e _ e n c o u n t e r s _ c o m b i n e d _ t b l   a s   (  
         / *   c o m b i n e   l a t e s t   v i s i t s   a n d   l a t e s t   p h a r m a c y   d i s p e n s a t i o n   r e c o r d s   a s   o f   d a t e   -   ' b o r r o w e d   l o g i c   f r o m   t h e   v i e w   v w _ P a t i e n t L a s t E n c o n t e r * /  
         / *   w e   d o n ' t   i n c l u d e   t h e   C T _ A R T P a t i e n t s   t a b l e   l o g i c   b e c a u s e   t h i s   t a b l e   h a s   o n l y   t h e   l a t e s t   r e c o r d s   o f   t h e   p a t i e n t s   ( n o   h i s t o r y )   * /  
         s e l e c t     d i s t i n c t   c o a l e s c e   ( l a s t _ v i s i t . P a t i e n t I D ,   l a s t _ d i s p e n s e . P a t i e n t I D )   a s   P a t i e n t I D ,  
                         c o a l e s c e ( l a s t _ v i s i t . S i t e C o d e ,   l a s t _ d i s p e n s e . S i t e C o d e )   a s   S i t e C o d e ,  
                         c o a l e s c e ( l a s t _ v i s i t . P a t i e n t P K ,   l a s t _ d i s p e n s e . P a t i e n t P K )   a s   P a t i e n t P K   ,  
                         c o a l e s c e ( l a s t _ v i s i t . E m r ,   l a s t _ d i s p e n s e . E m r )   a s   E m r ,  
                         c a s e  
                                 w h e n   l a s t _ v i s i t . V i s i t D a t e   > =   l a s t _ d i s p e n s e . D i s p e n s e D a t e   t h e n   l a s t _ v i s i t . V i s i t D a t e    
                                 e l s e   i s n u l l ( l a s t _ d i s p e n s e . D i s p e n s e D a t e ,   l a s t _ v i s i t . V i s i t D a t e )  
                         e n d   a s   L a s t E n c o u n t e r D a t e ,  
                         c a s e    
                                 w h e n   l a s t _ v i s i t . N e x t A p p o i n t m e n t D a t e   > =   l a s t _ d i s p e n s e . E x p e c t e d R e t u r n   t h e n   l a s t _ v i s i t . N e x t A p p o i n t m e n t D a t e    
                                 e l s e   i s n u l l ( l a s t _ d i s p e n s e . E x p e c t e d R e t u r n ,   l a s t _ v i s i t . N e x t A p p o i n t m e n t D a t e )      
                         e n d   a s   N e x t A p p o i n t m e n t D a t e  
         f r o m   l a s t _ v i s i t _ e n c o u n t e r _ a s _ o f _ d a t e   a s   l a s t _ v i s i t  
         f u l l   j o i n   l a s t _ p h a r m a c y _ d i s p e n s e _ a s _ o f _ d a t e   a s   l a s t _ d i s p e n s e   o n   l a s t _ v i s i t . P a t i e n t I D   =   l a s t _ d i s p e n s e . P a t i e n t I D    
                 a n d   l a s t _ v i s i t . S i t e C o d e   =   l a s t _ d i s p e n s e . S i t e C o d e    
                 a n d   l a s t _ v i s i t . P a t i e n t P K   =   l a s t _ d i s p e n s e . P a t i e n t P K  
         w h e r e    
                 c a s e  
                         w h e n   l a s t _ v i s i t . V i s i t D a t e   > =   l a s t _ d i s p e n s e . D i s p e n s e D a t e   t h e n   l a s t _ v i s i t . V i s i t D a t e    
                 e l s e   i s n u l l ( l a s t _ d i s p e n s e . D i s p e n s e D a t e ,   l a s t _ v i s i t . V i s i t D a t e )  
                 e n d   i s   n o t   n u l l  
 ) ,  
 l a s t _ e n c o u n t e r   a s   (  
         / *   p r e p a r i n g   t h e   l a t e s t   e n c o u n t e r   r e c o r d s   a s   o f   d a t e   * /  
         s e l e c t  
                 v i s i t s _ a n d _ d i s p e n s e _ e n c o u n t e r s _ c o m b i n e d _ t b l . P a t i e n t I D ,  
                 v i s i t s _ a n d _ d i s p e n s e _ e n c o u n t e r s _ c o m b i n e d _ t b l . S i t e C o d e ,  
                 v i s i t s _ a n d _ d i s p e n s e _ e n c o u n t e r s _ c o m b i n e d _ t b l . P a t i e n t P K ,  
                 v i s i t s _ a n d _ d i s p e n s e _ e n c o u n t e r s _ c o m b i n e d _ t b l . E m r ,  
                 v i s i t s _ a n d _ d i s p e n s e _ e n c o u n t e r s _ c o m b i n e d _ t b l . L a s t E n c o u n t e r D a t e ,  
                 c a s e    
                         w h e n   d a t e d i f f ( d d ,   @ a s _ o f _ d a t e ,   v i s i t s _ a n d _ d i s p e n s e _ e n c o u n t e r s _ c o m b i n e d _ t b l . N e x t A p p o i n t m e n t D a t e )   > =   3 6 5   t h e n   d a t e a d d ( d a y ,   3 0 ,   L a s t E n c o u n t e r D a t e )  
                         e l s e   v i s i t s _ a n d _ d i s p e n s e _ e n c o u n t e r s _ c o m b i n e d _ t b l . N e x t A p p o i n t m e n t D a t e    
                 e n d   A s   N e x t A p p o i n t m e n t D a t e          
         f r o m   v i s i t s _ a n d _ d i s p e n s e _ e n c o u n t e r s _ c o m b i n e d _ t b l  
 ) ,  
 A R T O u t c o m e s C o m p u a t i o n   a s   (  
         / *   c o m p u t i n g   t h e   A R T _ O u t c o m e   a s   o f   d a t e   -   ' b o r r o w e d   l o g i c   f r o m   t h e   v i e w   v w _ A R T O u t c o m e X ' * /  
         s e l e c t    
                 l a s t _ e n c o u n t e r . * ,  
                 p a t i e n t _ a r t _ a n d _ e n r o l l m e n t _ i n f o . s t a r t A R T D a t e ,  
                 l a s t _ e x i t _ a s _ o f _ d a t e . E x i t D a t e ,  
                 p a t i e n t _ a r t _ a n d _ e n r o l l m e n t _ i n f o . E n r o l l m e n t D a t e ,  
                 p a t i e n t _ a r t _ a n d _ e n r o l l m e n t _ i n f o . A g e E n r o l l m e n t ,  
                 p a t i e n t _ a r t _ a n d _ e n r o l l m e n t _ i n f o . S t a r t R e g i m e n ,  
                 p a t i e n t _ a r t _ a n d _ e n r o l l m e n t _ i n f o . S t a r t R e g i m e n L i n e ,  
                 p a t i e n t _ a r t _ a n d _ e n r o l l m e n t _ i n f o . D a t e C o n f i r m e d H I V P o s i t i v e ,  
                 p a t i e n t _ a r t _ a n d _ e n r o l l m e n t _ i n f o . G e n d e r ,  
                 d a t e d i f f ( y e a r ,   p a t i e n t _ a r t _ a n d _ e n r o l l m e n t _ i n f o . D O B ,   l a s t _ e n c o u n t e r . L a s t E n c o u n t e r D a t e )   a s   A g e L a s t V i s i t ,  
                 c a s e    
                         w h e n   l a t e s t _ e f f e c t i v e _ d i s c o n t i n u a t i o n . E x i t D a t e   i s   n o t   n u l l    
                                 a n d   l a t e s t _ e f f e c t i v e _ d i s c o n t i n u a t i o n . E x i t R e a s o n   < >   ' D I E D '    
                                 a n d   l a t e s t _ e f f e c t i v e _ d i s c o n t i n u a t i o n . E f f e c t i v e D i s c o n t i n u a t i o n D a t e   >   e o m o n t h ( @ a s _ o f _ d a t e )   t h e n   ' V '  
                         w h e n   p a t i e n t _ a r t _ a n d _ e n r o l l m e n t _ i n f o . s t a r t A R T D a t e   >   d a t e a d d ( s , - 1 , d a t e a d d ( m m ,   d a t e d i f f ( m , 0 ,   @ a s _ o f _ d a t e )   +   1   , 0 ) )   t h e n   ' N P '  
                         w h e n   l a s t _ e x i t _ a s _ o f _ d a t e . E x i t D a t e   i s   n o t   n u l l   t h e n   s u b s t r i n g ( l a s t _ e x i t _ a s _ o f _ d a t e . E x i t R e a s o n ,   1 ,   1 )  
                         w h e n   e o m o n t h ( @ a s _ o f _ d a t e )   <   l a s t _ e n c o u n t e r . N e x t A p p o i n t m e n t D a t e  
 	 	 	     o r   d a t e d i f f ( d d ,   l a s t _ e n c o u n t e r . N e x t A p p o i n t m e n t D a t e ,   e o m o n t h ( @ a s _ o f _ d a t e ) )   < =   3 0   t h e n   ' V '  
                         w h e n   d a t e d i f f ( d d ,   l a s t _ e n c o u n t e r . N e x t A p p o i n t m e n t D a t e ,   e o m o n t h ( @ a s _ o f _ d a t e ) )   >   3 0   t h e n   ' u L '  
                         w h e n   N e x t A p p o i n t m e n t D a t e   i s   n u l l   t h e n   ' N V '  
                 e n d   a s   A R T O u t c o m e ,  
                 @ a s _ o f _ d a t e   a s   A s O f D a t e  
         f r o m   l a s t _ e n c o u n t e r  
         l e f t   j o i n   l a t e s t _ e f f e c t i v e _ d i s c o n t i n u a t i o n   o n   l a t e s t _ e f f e c t i v e _ d i s c o n t i n u a t i o n . P a t i e n t I D   =   l a s t _ e n c o u n t e r . P a t i e n t I D  
                 a n d   l a t e s t _ e f f e c t i v e _ d i s c o n t i n u a t i o n . P a t i e n t P K   =   l a s t _ e n c o u n t e r . P a t i e n t P K  
                 a n d   l a t e s t _ e f f e c t i v e _ d i s c o n t i n u a t i o n . S i t e C o d e   =   l a s t _ e n c o u n t e r . S i t e C o d e  
         l e f t   j o i n   l a s t _ e x i t _ a s _ o f _ d a t e   o n   l a s t _ e x i t _ a s _ o f _ d a t e . P a t i e n t I D   =   l a s t _ e n c o u n t e r . P a t i e n t I D  
                 a n d   l a s t _ e x i t _ a s _ o f _ d a t e . P a t i e n t P K   =   l a s t _ e n c o u n t e r . P a t i e n t P K  
                 a n d   l a s t _ e x i t _ a s _ o f _ d a t e . S i t e C o d e   =   l a s t _ e n c o u n t e r . S i t e C o d e  
         l e f t   j o i n   p a t i e n t _ a r t _ a n d _ e n r o l l m e n t _ i n f o   o n   p a t i e n t _ a r t _ a n d _ e n r o l l m e n t _ i n f o . P a t i e n t I D   =   l a s t _ e n c o u n t e r . P a t i e n t I D  
                 a n d   p a t i e n t _ a r t _ a n d _ e n r o l l m e n t _ i n f o . P a t i e n t P K   =   l a s t _ e n c o u n t e r . P a t i e n t P K  
                 a n d   p a t i e n t _ a r t _ a n d _ e n r o l l m e n t _ i n f o . S i t e C o d e   =   l a s t _ e n c o u n t e r . S i t e C o d e  
 )  
 i n s e r t   i n t o   d b o . H i s t o r i c a l A R T O u t c o m e s B a s e T a b l e  
 s e l e c t    
 	 A R T O u t c o m e s C o m p u a t i o n . P a t i e n t I D   a s   P a t i e n t I D ,  
         A R T O u t c o m e s C o m p u a t i o n . P a t i e n t P K ,  
         A R T O u t c o m e s C o m p u a t i o n . S i t e C o d e   a s   M F L C o d e ,  
         A R T O u t c o m e s C o m p u a t i o n . A R T O u t c o m e ,  
 	 A R T O u t c o m e s C o m p u a t i o n . A s O f D a t e  
 f r o m   A R T O u t c o m e s C o m p u a t i o n  
  
 f e t c h   n e x t   f r o m   c u r s o r _ A s O f D a t e s   i n t o   @ a s _ o f _ d a t e  
 e n d  
  
  
 - - f r e e   u p   o b j e c t s  
 d r o p   t a b l e   # m o n t h s  
 c l o s e   c u r s o r _ A s O f D a t e s  
 d e a l l o c a t e   c u r s o r _ A s O f D a t e s 