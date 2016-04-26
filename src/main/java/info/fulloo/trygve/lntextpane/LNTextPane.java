package info.fulloo.trygve.lntextpane;

/*
 * Trygve IDE 2.0
 *   Copyright (c)2016 James O. Coplien, jcoplien@gmail.com
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 * 
 *  For further information about the trygve project, please contact
 *  Jim Coplien at jcoplien@gmail.com
 * 
 */

// http://www.developer.com/java/other/article.php/3318421/Add-Line-Numbering-in-the-JEditorPane.htm

import javax.swing.*;
import javax.swing.text.AttributeSet;
import javax.swing.text.DefaultStyledDocument;
import javax.swing.text.Document;
import javax.swing.text.PlainDocument;
import javax.swing.text.SimpleAttributeSet;
import javax.swing.text.StyleConstants;
import javax.swing.text.TabSet;
import javax.swing.text.TabStop;

public class LNTextPane extends JFrame {
	private void setTabStops() {
		final Document doc = edit_.getDocument();
        if (doc instanceof PlainDocument) {
            doc.putProperty(PlainDocument.tabSizeAttribute, 8);
        } else if (doc instanceof DefaultStyledDocument) {
        	TabStop[] tabs = new TabStop[20];
        	for (int i = 0; i < 20; i++) tabs[i] = new TabStop((i+1) * 20);
        	TabSet tabSet = new TabSet(tabs);
            SimpleAttributeSet attributes = new SimpleAttributeSet();
            StyleConstants.setTabSet(attributes, tabSet);
            int length = doc.getLength();
            ((DefaultStyledDocument) doc).setParagraphAttributes(0, length, attributes, false);
        }
	}
    public LNTextPane() {
        edit_ = new JEditorPane();
        edit_.setEditorKit(new NumberedEditorKit());

        setTabStops();
        
        scroll_ = new JScrollPane(edit_);
        getContentPane().add(scroll_);
        setSize(300, 300);
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setVisible(true);
    }
    public JScrollPane scrollPane()
    {
    	return scroll_;
    }
    public JEditorPane editPane()
    {
    	return edit_;
    }
    private JScrollPane scroll_;
    private JEditorPane edit_;
    
    static final long serialVersionUID = 991540;
}